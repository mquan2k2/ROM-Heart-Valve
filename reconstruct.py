import os
import numpy as np


def reconstruct_pod_flowfields(projectNames, n):
    """
    Reconstruct flowfields using POD modes 1..n for one or more projects.

    Parameters
    ----------
    projectNames : list[str]
        List of project name prefixes.
    n : int
        Number of POD modes to use in the reconstruction.

    Notes
    -----
    Assumes:
    - Spatial POD modes are stored as:
          {projectName}_podMode_{i}.txt
    - Temporal POD modes (rows of V^T) are stored as:
          {projectName}_podTempMode_{i}.txt
    - Singular values are stored as:
          {projectName}_SV.txt

    Reconstruction formula:
        snapshot_j ~= sum_{i=1}^n sigma_i * phi_i * a_i[j]

    Output files:
        {projectName}_reconFlowfield_{n}_modes_{j}.npy
    where j goes from 1 to number of snapshots.
    """

    if isinstance(projectNames, str):
        projectNames = [projectNames]

    if n < 1:
        raise ValueError("n must be at least 1.")

    print("\n====================================================")
    print("           POD FLOWFIELD RECONSTRUCTION")
    print("====================================================\n")

    for projectName in projectNames:
        print(f"--- Working on project: {projectName} ---")

        # -------------------------------------------------
        # Load singular values
        # -------------------------------------------------
        sv_file = f"{projectName}_SV.txt"
        if not os.path.exists(sv_file):
            print(f"  ERROR: Missing singular value file: {sv_file}")
            print("  Skipping this project.\n")
            continue

        S = np.loadtxt(sv_file)
        S = np.atleast_1d(S).flatten()

        total_available_modes = len(S)
        print(f"  Total singular values available: {total_available_modes}")

        if n > total_available_modes:
            print(f"  WARNING: Requested n = {n}, but only {total_available_modes} modes exist.")
            print(f"  Using n = {total_available_modes} instead.")
            n_use = total_available_modes
        else:
            n_use = n

        print(f"  Number of modes to reconstruct with: {n_use}")

        # -------------------------------------------------
        # Load first mode and first temporal coefficient
        # to determine sizes
        # -------------------------------------------------
        first_mode_file = f"{projectName}_podMode_1.txt"
        first_temp_file = f"{projectName}_podTempMode_1.txt"

        if not os.path.exists(first_mode_file):
            print(f"  ERROR: Missing spatial mode file: {first_mode_file}")
            print("  Skipping this project.\n")
            continue

        if not os.path.exists(first_temp_file):
            print(f"  ERROR: Missing temporal mode file: {first_temp_file}")
            print("  Skipping this project.\n")
            continue

        phi1_raw = np.loadtxt(first_mode_file)
        phi_shape = phi1_raw.shape
        phi_size = phi1_raw.size

        a1 = np.loadtxt(first_temp_file)
        a1 = np.atleast_1d(a1).flatten()
        num_snapshots = len(a1)

        print(f"  Spatial mode shape: {phi_shape}")
        print(f"  Spatial mode total entries: {phi_size}")
        print(f"  Number of snapshots to reconstruct: {num_snapshots}")

        # -------------------------------------------------
        # Preload modes and temporal coefficients
        # -------------------------------------------------
        spatial_modes = []
        temporal_modes = []

        print("  Loading required POD modes and temporal coefficients...")

        valid_mode_count = 0
        for i in range(1, n_use + 1):
            mode_file = f"{projectName}_podMode_{i}.txt"
            temp_file = f"{projectName}_podTempMode_{i}.txt"

            if not os.path.exists(mode_file):
                print(f"  WARNING: Missing spatial mode file: {mode_file}")
                print(f"           Stopping at mode {i-1}.")
                break

            if not os.path.exists(temp_file):
                print(f"  WARNING: Missing temporal mode file: {temp_file}")
                print(f"           Stopping at mode {i-1}.")
                break

            phi_i_raw = np.loadtxt(mode_file)
            a_i = np.loadtxt(temp_file)

            phi_i = np.asarray(phi_i_raw).reshape(-1)
            a_i = np.atleast_1d(a_i).flatten()

            if phi_i.size != phi_size:
                raise ValueError(
                    f"Inconsistent size in {mode_file}: "
                    f"expected {phi_size}, got {phi_i.size}"
                )

            if len(a_i) != num_snapshots:
                raise ValueError(
                    f"Inconsistent number of snapshots in {temp_file}: "
                    f"expected {num_snapshots}, got {len(a_i)}"
                )

            spatial_modes.append(phi_i)
            temporal_modes.append(a_i)
            valid_mode_count += 1

            print(f"    Loaded mode {i}")

        if valid_mode_count == 0:
            print("  ERROR: No valid modes were loaded.")
            print("  Skipping this project.\n")
            continue

        if valid_mode_count < n_use:
            print(f"  WARNING: Only {valid_mode_count} modes were successfully loaded.")
            n_use = valid_mode_count

        spatial_modes = np.array(spatial_modes)      # shape: (n_use, phi_size)
        temporal_modes = np.array(temporal_modes)    # shape: (n_use, num_snapshots)
        singular_values = S[:n_use]                  # shape: (n_use,)

        print(f"  Final number of modes used: {n_use}")
        print(f"  spatial_modes array shape: {spatial_modes.shape}")
        print(f"  temporal_modes array shape: {temporal_modes.shape}")
        print(f"  singular_values shape: {singular_values.shape}")

        # -------------------------------------------------
        # Reconstruct each snapshot
        # -------------------------------------------------
        print("  Beginning reconstruction of snapshots...")

        for j in range(num_snapshots):
            coeffs_j = singular_values * temporal_modes[:, j]
            recon_flat = np.sum(coeffs_j[:, None] * spatial_modes, axis=0)
            recon_field = recon_flat.reshape(phi_shape)

            out_file = f"{projectName}_reconFlowfield_{n_use}_modes_{j+1}.npy"
            np.save(out_file, recon_field)

            if (j + 1) == 1 or (j + 1) == num_snapshots or (j + 1) % max(1, num_snapshots // 10) == 0:
                print(f"    Saved snapshot {j+1}/{num_snapshots} -> {out_file}")

        print(f"  Finished reconstruction for project: {projectName}")
        print("")

    print("====================================================")
    print("           RECONSTRUCTION COMPLETE")
    print("====================================================\n")


# ------------------------------------------------------------------
# Example usage
# ------------------------------------------------------------------
if __name__ == "__main__":
    projectNames = ["case03", "case05", "case075"]
    n = 5
    reconstruct_pod_flowfields(projectNames, n)