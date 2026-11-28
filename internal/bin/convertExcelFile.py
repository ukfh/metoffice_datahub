#!/usr/bin/env python3
"""Convert hourly humidity and temperature workbooks to logger text."""

import argparse
import re
import sys
from datetime import date, datetime, time, timedelta, timezone
from pathlib import Path

try:
    from openpyxl import load_workbook
except ImportError as exc:
    raise SystemExit(
        "Missing dependency: install openpyxl with 'python -m pip install openpyxl'."
    ) from exc


ROOT = Path(__file__).resolve().parents[2]
DATA = ROOT / "data"
DEFAULT_HUMIDITY = (
    DATA / "History_humidity_2025.11.24-2026.11.24_UTC 0 1795547110284.xlsx"
)
DEFAULT_TEMPERATURE = (
    DATA / "History_temperature_2025.11.24-2026.11.24_UTC 0 1795547063827.xlsx"
)
DEFAULT_OUTPUT_NAME = "History_2025.11.24-2026.11.24_UTC.txt"
INTERVAL_PATTERN = re.compile(r"^\s*(\d{1,2}:\d{2})\s*-\s*(\d{1,2}:\d{2})\s*$")


def parse_date(value):
    if isinstance(value, datetime):
        return value.date()
    if isinstance(value, date):
        return value
    for date_format in ("%Y/%m/%d", "%Y-%m-%d"):
        try:
            return datetime.strptime(str(value), date_format).date()
        except ValueError:
            pass
    raise ValueError(f"Unrecognized date: {value!r}")


def read_averages(path, average_header):
    workbook = load_workbook(path, read_only=True, data_only=True)
    try:
        worksheet = workbook.active
        rows = worksheet.iter_rows(values_only=True)
        headers = next(rows, None)
        if not headers:
            raise ValueError(f"{path}: workbook is empty")
        try:
            date_column = headers.index("Date")
            time_column = headers.index("Time")
            average_column = headers.index(average_header)
        except ValueError as exc:
            raise ValueError(
                f"{path}: expected columns Date, Time, and {average_header}"
            ) from exc

        averages = {}
        occurrences = {}
        for row_number, row in enumerate(rows, start=2):
            if not row or all(value is None for value in row):
                continue
            try:
                day = parse_date(row[date_column])
                interval = INTERVAL_PATTERN.fullmatch(str(row[time_column]))
                if interval is None:
                    raise ValueError(f"invalid hourly interval: {row[time_column]!r}")
                start = datetime.combine(
                    day, datetime.strptime(interval.group(1), "%H:%M").time()
                )
                end_time = datetime.strptime(interval.group(2), "%H:%M").time()
                end = datetime.combine(day, end_time)
                if end < start:
                    end += timedelta(days=1)
                average = float(row[average_column])
                occurrence = occurrences.get(start, 0)
                occurrences[start] = occurrence + 1
                averages[(start, occurrence)] = ((start, end), average)
            except (TypeError, ValueError) as exc:
                raise ValueError(f"{path}: row {row_number}: {exc}") from exc
        return averages
    finally:
        workbook.close()


def format_value(value):
    return f"{value:.1f}"


def convert(humidity_path, temperature_path, output_path, start_date=None):
    humidity = read_averages(humidity_path, "Avg/%")
    temperature = read_averages(temperature_path, "Avg/℃")
    if humidity.keys() != temperature.keys():
        missing_temperature = sorted(humidity.keys() - temperature.keys())
        missing_humidity = sorted(temperature.keys() - humidity.keys())
        raise ValueError(
            "The workbooks contain different hourly intervals "
            f"({len(missing_temperature)} missing temperature, "
            f"{len(missing_humidity)} missing humidity)."
        )

    with output_path.open("w", encoding="utf-8", newline="\n") as output:
        output.write("# Generated from hourly humidity and temperature exports\n")
        output.write("# fileformat=dat append=false\n")
        output.write(
            "# UNIX time [s] Temperature [°C] Humidity [%]  Date Time "
            "Dew Point [°C] Water content [g/m³]\n#\n"
        )
        for interval_key in sorted(temperature):
            (interval_start, interval_end), temp_value = temperature[interval_key]
            if start_date is not None and interval_start.date() < start_date:
                continue
            _, humidity_value = humidity[interval_key]
            midpoint = interval_start + (interval_end - interval_start) / 2
            epoch = int(midpoint.replace(tzinfo=timezone.utc).timestamp())
            output.write(
                f"{epoch} {format_value(temp_value)} {format_value(humidity_value)} "
                f"0 {midpoint:%d.%m.%Y} {midpoint:%H:%M:%S} 0 0\n"
            )


def main():
    parser = argparse.ArgumentParser(
        description="Convert hourly humidity and temperature Excel exports "
        "to the text format used by the internal data ingester."
    )
    parser.add_argument(
        "--hum", type=Path, default=DEFAULT_HUMIDITY, metavar="FILE",
        help="humidity workbook",
    )
    parser.add_argument(
        "--temp", type=Path, default=DEFAULT_TEMPERATURE, metavar="FILE",
        help="temperature workbook",
    )
    parser.add_argument(
        "--outdir", type=Path, default=DATA, metavar="DIRECTORY",
        help="directory for the converted output file",
    )
    parser.add_argument(
        "--start-date",
        type=date.fromisoformat,
        metavar="YYYY-MM-DD",
        help="discard observations before this date (inclusive start date)",
    )
    args = parser.parse_args()
    output_path = args.outdir / DEFAULT_OUTPUT_NAME

    try:
        args.outdir.mkdir(parents=True, exist_ok=True)
        convert(args.hum, args.temp, output_path, args.start_date)
    except (OSError, ValueError) as exc:
        print(f"Conversion failed: {exc}", file=sys.stderr)
        return 1
    print(f"Wrote converted data to {output_path}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())