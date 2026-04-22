import numpy as np
import os

# =========================================================
# Fill in your file paths here
# =========================================================
valves = [0.3, 0.5, 0.75]
n_modes = 5   # 和你reconstruct时一致

for v in valves:
    projectName = f"Valve_{v}mm"

    coords_file = "C:/Users/28027/Desktop/Flow_Field/FlowField0.5/snapshots_POD/coords.txt"

    for j in range(1, 100):
        velocity_file = f"C:/Users/28027/Desktop/Flow_Field/Reconstruct/Reconstructed/{projectName}_reconFlowfield_{n_modes}_modes_{j}.npy"
        
        # 👉 输出（还是原命名，只是内容多了Q）
        output_file = f"C:/Users/28027/Desktop/Flow_Field/Reconstruct/Reconstructed_techplot/{projectName}_reconFlowfield_{n_modes}_modes_{j}.dat"

        if not os.path.exists(velocity_file):
            continue

        print(f"Processing: {velocity_file}")

        # =========================================================
        # Read coordinates
        # =========================================================
        coords = np.loadtxt(coords_file, delimiter=",")

        if coords.ndim != 2 or coords.shape[1] != 3:
            raise ValueError(
                f"Coordinate file must have shape (n, 3), but got {coords.shape}"
            )

        n = coords.shape[0]

        # =========================================================
        # Read velocity
        # =========================================================
        vel_raw = np.load(velocity_file)
        vel_raw = np.asarray(vel_raw).reshape(-1)

        if vel_raw.size != 3 * n:
            raise ValueError(
                f"Velocity file length must be 3*n = {3*n}, but got {vel_raw.size}"
            )

        ux = vel_raw[0:n]
        uy = vel_raw[n:2*n]
        uz = vel_raw[2*n:3*n]

        # =========================================================
        # 排序（保证structured grid）
        # =========================================================
        sort_idx = np.lexsort((coords[:, 0], coords[:, 1], coords[:, 2]))

        coords = coords[sort_idx]
        ux = ux[sort_idx]
        uy = uy[sort_idx]
        uz = uz[sort_idx]

        # =========================================================
        # reshape 成 3D grid
        # =========================================================
        x_unique = np.unique(coords[:, 0])
        y_unique = np.unique(coords[:, 1])
        z_unique = np.unique(coords[:, 2])

        nx, ny, nz = len(x_unique), len(y_unique), len(z_unique)

        if nx * ny * nz != n:
            raise ValueError("Grid is not structured!")

        U = ux.reshape((nx, ny, nz), order="F")
        V = uy.reshape((nx, ny, nz), order="F")
        W = uz.reshape((nx, ny, nz), order="F")

        # =========================================================
        # 计算速度梯度
        # =========================================================
        du_dx, du_dy, du_dz = np.gradient(U, x_unique, y_unique, z_unique, edge_order=2)
        dv_dx, dv_dy, dv_dz = np.gradient(V, x_unique, y_unique, z_unique, edge_order=2)
        dw_dx, dw_dy, dw_dz = np.gradient(W, x_unique, y_unique, z_unique, edge_order=2)

        # =========================================================
        # Q-criterion
        # =========================================================
        S11 = du_dx
        S22 = dv_dy
        S33 = dw_dz

        S12 = 0.5 * (du_dy + dv_dx)
        S13 = 0.5 * (du_dz + dw_dx)
        S23 = 0.5 * (dv_dz + dw_dy)

        O12 = 0.5 * (du_dy - dv_dx)
        O13 = 0.5 * (du_dz - dw_dx)
        O23 = 0.5 * (dv_dz - dw_dy)

        S_norm_sq = (
            S11**2 + S22**2 + S33**2
            + 2*(S12**2 + S13**2 + S23**2)
        )

        O_norm_sq = 2*(O12**2 + O13**2 + O23**2)

        Q = 0.5 * (O_norm_sq - S_norm_sq)

        # =========================================================
        # flatten Q
        # =========================================================
        Q_flat = Q.ravel(order="F")

        # =========================================================
        # Combine: XYZ + UVW + Q
        # =========================================================
        output_data = np.column_stack((coords, ux, uy, uz, Q_flat))

        # =========================================================
        # Write Tecplot
        # =========================================================
        with open(output_file, "w") as f:
            f.write('TITLE = "Vector Field + Q"\n')
            f.write('VARIABLES = "X" "Y" "Z" "U" "V" "W" "Q"\n')
            f.write(f'ZONE F=POINT, I=402, J=132, K=132\n')  # 这里你原来的就没动

            np.savetxt(f, output_data, fmt="%.10e", delimiter=",")

        print(f"Done. Tecplot file written to:\n{output_file}")