% ---- 基本参数 ----
n = 7004448;
folder = 'C:\Users\28027\Desktop\Flow_Field\FlowField0.5\snapshots\';
ds        = 2;
sliceStep = 5;

% ---- 读坐标（共用一次）----
c  = readmatrix(fullfile(folder, 'coords.txt'));   % [n×3], columns: x y z
x  = unique(c(:,1));  nx = numel(x);
y  = unique(c(:,2));  ny = numel(y);
z  = unique(c(:,3));  nz = numel(z);

[~,ix] = ismember(c(:,1), x);
[~,iy] = ismember(c(:,2), y);
[~,iz] = ismember(c(:,3), z);
lin    = sub2ind([ny,nx,nz], iy, ix, iz);

[X,Y,Z] = meshgrid(x, y, z);

% ---- 读四个 mode 的速度场 ----
numModes = 4;
Vx = nan(ny, nx, nz, numModes);
Vy = Vx;
Vz = Vx;

for m = 1:numModes
    fname  = sprintf('Valve_0.5mm_Avg_Mode_%d.txt', m);
    fprintf('Reading %s ...\n', fname);
    Vfield = readmatrix(fullfile(folder, fname));

    vx = Vfield(1:n,1);
    vy = Vfield(n+1:2*n,1);
    vz = Vfield(2*n+1:3*n,1);

    tmp = nan(ny,nx,nz);
    tmp(lin) = vx;  Vx(:,:,:,m) = tmp;
    tmp(lin) = vy;  Vy(:,:,:,m) = tmp;
    tmp(lin) = vz;  Vz(:,:,:,m) = tmp;
end

% ---- 切片索引 ----
z_idx = 1:sliceStep:nz;
x_idx = [1:5:250, 255:10:400];

%% ===== XY 平面（颜色=U）=====
gMinXY = inf; gMaxXY = -inf;
for k = z_idx
    for m = 1:4
        U = Vx(:,:,k,m);
        Ud = U(1:ds:end,1:ds:end);
        Ud = Ud(isfinite(Ud));
        if ~isempty(Ud)
            gMinXY = min(gMinXY, min(Ud));
            gMaxXY = max(gMaxXY, max(Ud));
        end
    end
end
mx = max(abs([gMinXY gMaxXY]));
climGlobalXY = [-mx, mx];

outdir_xy = 'C:\Users\28027\Desktop\Flow_Field\FlowField0.5\plots_xy';
if ~exist(outdir_xy, 'dir'), mkdir(outdir_xy); end

for k = z_idx
    f = figure('Visible','off', 'Name', sprintf('XY slice: z-idx %d, z=%.6g', k, z(k)));
    t = tiledlayout(2,2,'TileSpacing','compact','Padding','compact');

    Xp = X(:,:,k); Yp = Y(:,:,k);
    for m = 1:4
        U = Vx(:,:,k,m); 
        V = Vy(:,:,k,m);
        Xd = Xp(1:ds:end,1:ds:end); 
        Yd = Yp(1:ds:end,1:ds:end);
        Ud = U (1:ds:end,1:ds:end); 
        Vd = V (1:ds:end,1:ds:end);

        ax = nexttile;
        contourf(Xd, Yd, Ud, 12, 'LineStyle','none'); hold on;
        quiver(Xd, Yd, Ud, Vd, 'AutoScale','on','AutoScaleFactor',1.0, ...
               'Color','k','MaxHeadSize',0.8);
        axis equal tight; box on;
        xlabel('x'); ylabel('y'); title(sprintf('Mode %d', m));
        caxis(climGlobalXY);
    end
    cb = colorbar; cb.Layout.Tile = 'east'; cb.Label.String = 'U (x-velocity)';
    title(t, sprintf('Velocity field on XY plane @ z = %.6g', z(k)));

    exportgraphics(f, fullfile(outdir_xy, sprintf('XY_zidx_%03d_z%.4f.png', k, z(k))), 'Resolution', 300);
    close(f);
end

%% ===== YZ 平面（颜色=U）=====
gMin = inf; gMax = -inf;
for i = x_idx
    for m = 1:4
        U = squeeze(Vx(:,i,:,m));
        Ud = U(1:ds:end,1:ds:end);
        Ud = Ud(isfinite(Ud));
        if ~isempty(Ud)
            gMin = min(gMin, min(Ud));
            gMax = max(gMax, max(Ud));
        end
    end
end
mx = max(abs([gMin gMax]));
climGlobal = [-mx, mx];

outdir_yz = 'C:\Users\28027\Desktop\Flow_Field\FlowField0.5\plots_yz';
if ~exist(outdir_yz, 'dir'), mkdir(outdir_yz); end

for i = x_idx
    f = figure('Visible','off', 'Name', sprintf('YZ slice: x-idx %d, x=%.6g', i, x(i)));
    t = tiledlayout(2,2,'TileSpacing','compact','Padding','compact');

    Yp = squeeze(Y(:,i,:)); 
    Zp = squeeze(Z(:,i,:));
    for m = 1:4
        U = squeeze(Vx(:,i,:,m)); 
        V = squeeze(Vy(:,i,:,m)); 
        W = squeeze(Vz(:,i,:,m));
        Yd = Yp(1:ds:end,1:ds:end); 
        Zd = Zp(1:ds:end,1:ds:end);
        Ud = U(1:ds:end,1:ds:end);
        Vd = V(1:ds:end,1:ds:end); 
        Wd = W(1:ds:end,1:ds:end);

        ax = nexttile;
        contourf(Yd, Zd, Ud, 12, 'LineStyle','none'); hold on;
        quiver(Yd, Zd, Vd, Wd, 'AutoScale','on','AutoScaleFactor',1.0, ...
               'Color','k','MaxHeadSize',0.8);
        axis equal tight; box on;
        xlabel('y'); ylabel('z'); title(sprintf('Mode %d', m));
        caxis(climGlobal);
    end
    cb = colorbar; cb.Layout.Tile = 'east'; cb.Label.String = 'U (x-velocity)';
    title(t, sprintf('Velocity field on YZ plane @ x = %.6g', x(i)));

    exportgraphics(f, fullfile(outdir_yz, sprintf('YZ_xidx_%03d_x%.4f.png', i, x(i))), 'Resolution', 300);
    close(f);
end

