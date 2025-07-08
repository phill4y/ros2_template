#!/usr/bin/env python3

import argparse
from pathlib import Path
import subprocess
import sys

REPO_DIR = Path(__file__).parent.parent
ROS2_DIR = REPO_DIR / "ros2" / "ros2_ws"


def get_package_executables(package_name: str) -> list[str]:
    # Build the shell command
    command = (
        f". {ROS2_DIR}/install/setup.sh && ros2 pkg executables {package_name} | awk '{{print $2}}'"
    )
    result = subprocess.run(
        ["bash", "-c", command],
        capture_output=True,
        text=True
    )
    if result.returncode != 0:
        print(f"Error running ros2 command:\n{result.stderr}", file=sys.stderr)
        sys.exit(result.returncode)

    executables = result.stdout.strip().splitlines()
    # Ignore Python scripts
    return [x for x in executables if ".py" not in x]


def main():
    parser = argparse.ArgumentParser(description="List executables for a ROS2 package")
    parser.add_argument("package", help="Name of the ROS2 package")
    args = parser.parse_args()

    executables = get_package_executables(args.package)
    # executables = get_package_executables("example_package")
    print("\n".join(executables))


if __name__ == "__main__":
    main()
