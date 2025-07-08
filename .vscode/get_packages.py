#!/usr/bin/env python3

from pathlib import Path
import subprocess


REPO_DIR = Path(__file__).parent.parent
ROS2_DIR = REPO_DIR / "ros2" / "ros2_ws"


def get_local_ros2_package_names() -> list[str]:
    # Use colcon list to get all packages within ROS2 workspace
    result = subprocess.run(["colcon", "list"], capture_output=True, text=True, cwd=ROS2_DIR)
    if result.returncode != 0:
        print("Error: Ensure you are running this script in a ROS2 workspace.")
        return []
    # Extract package names and paths from the colcon list output
    packages = []
    for line in result.stdout.splitlines():
        package_name, package_path = line.split()[0], line.split()[1]
        # Ignore packages under the extern directory
        if "extern" not in package_path:
            # Only select packages that are installed and have a config file
            config_path = ROS2_DIR / "install" / package_name / "share" / package_name / "config" / "config.yml"
            if config_path.exists():
                packages.append(package_name)
    return packages


def main():
    packages = get_local_ros2_package_names()
    print("\n".join(packages))


if __name__ == "__main__":
    main()
