import glob
import os

import numpy as np

# =========================================================
# User inputs
# =========================================================
projectName = "Valve_0.75mm"

# 目标点坐标，改成你要 probe 的点
target_xyz = np.array([0.0, 0.0, 0.0], dtype=float)

# 如果最近点离目标点太远，就报错；设为 None 表示关闭检查
max_distance = None

# 文件路径
coords_file = r"D:\Flow_Field\FlowField0.3\snapshots\coords.txt"
snapshot_folder = r"D:\Flow_Field\FlowField0.3\snapshots"
output_folder = r"C:\Users\28027\Desktop\Flow_Field\Probing_results"

# 快照文件名里有的项目写成 SnapShot，有的写成 snapShot
snapshot_patterns = [
    os.path.join(snapshot_folder, f"{projectName}_SnapShot_*.txt"),
    os.path.join(snapshot_folder, f"{projectName}_snapShot_*.txt"),
]


# =========================================================
# Read coords and find point index
# =========================================================
coords = np.loadtxt(coords_file, delimiter=",")

if coords.ndim != 2 or coords.shape[1] != 3:
    raise ValueError(f"coords file shape should be (N, 3), but got {coords.shape}")

n_points = coords.shape[0]

# 找最近点
dist2 = np.sum((coords - target_xyz) ** 2, axis=1)
index = int(np.argmin(dist2))
matched_xyz = coords[index]
matched_distance = float(np.sqrt(dist2[index]))

if max_distance is not None and matched_distance > max_distance:
    raise ValueError(
        f"Nearest point is too far from target: distance={matched_distance:.6e}, "
        f"max_distance={max_distance:.6e}"
    )

print("Target xyz:   ", target_xyz)
print("Matched xyz:  ", matched_xyz)
print("Point index:  ", index)
print("Match dist:   ", matched_distance)

# =========================================================
# Probe all snapshots
# =========================================================
snapshot_files = []
for pattern in snapshot_patterns:
    snapshot_files.extend(glob.glob(pattern))

snapshot_files = sorted(set(snapshot_files))

if not snapshot_files:
    raise FileNotFoundError(
        "No snapshot files found. Checked patterns:\n" + "\n".join(snapshot_patterns)
    )

print("Snapshot count:", len(snapshot_files))

result = np.zeros((len(snapshot_files), 3), dtype=float)

for i, snapshot_file in enumerate(snapshot_files):
    data = np.loadtxt(snapshot_file)
    data = np.asarray(data).reshape(-1)

    if data.size != 3 * n_points:
        raise ValueError(
            f"{snapshot_file} has length {data.size}, expected {3 * n_points}"
        )

    u = data[index]
    v = data[index + n_points]
    w = data[index + 2 * n_points]

    result[i, :] = [u, v, w]

# =========================================================
# Save result
# =========================================================
os.makedirs(output_folder, exist_ok=True)

output_name = (
    f"{projectName}_x{matched_xyz[0]:.6f}_"
    f"y{matched_xyz[1]:.6f}_"
    f"z{matched_xyz[2]:.6f}_probing.npy"
)
output_file = os.path.join(output_folder, output_name)

np.save(output_file, result)

print(f"Saved probing result to:\n{output_file}")
