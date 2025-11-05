% ----固定不变的部分（只读一次）----
n = 7004448;
folder = 'C:\Users\28027\Desktop\Flow_Field\FlowField0.5\snapshots\';
c = readmatrix(fullfile(folder,'coords.txt'));   % [n×3], columns: x y z

x = unique(c(:,1));  nx = numel(x);
y = unique(c(:,2));  ny = numel(y);
z = unique(c(:,3));  nz = numel(z);

[~,ix] = ismember(c(:,1), x);
[~,iy] = ismember(c(:,2), y);
[~,iz] = ismember(c(:,3), z);
lin = sub2ind([ny,nx,nz], iy, ix, iz);  % 重排索引

[X,Y,Z] = meshgrid(x, y, z);

contourNum = 2;
times = [15 20 25 30];

% ----沿y方向偏移的步长----
Ly = y(end) - y(1);
gapRatio = 0.10;
offsetY  = Ly * (1 + gapRatio);

figure; ax = axes; hold(ax, 'on');

for k = 1:numel(times)
    t = times(k);

    fname = sprintf('Valve_0.5mm_Snapshot_%04d.txt', t);
    %fname = sprintf( 'Valve_0.5mm_Avg_Mode_1.txt' );
    Vfield = readmatrix(fullfile(folder, fname));

    vx = Vfield(1:n,1);
    vy = Vfield(n+1:2*n,1);
    vz = Vfield(2*n+1:3*n,1);

    Vx = nan(ny,nx,nz); Vy = Vx; Vz = Vx;
    Vx(lin) = vx;  Vy(lin) = vy;  Vz(lin) = vz;

    [curlx, curly, curlz, ~] = curl(X, Y, Z, Vx, Vy, Vz);
    omegaMag = curlx;

    % ----换成沿Y方向平移----
    Ys = Y + (k-1)*offsetY;

    p = patch(isosurface(X, Ys, Z, omegaMag,  contourNum));
    isonormals(X, Ys, Z, omegaMag, p);
    set(p, 'FaceColor', 'red',  'EdgeColor', 'none');

    q = patch(isosurface(X, Ys, Z, omegaMag, -contourNum));
    isonormals(X, Ys, Z, omegaMag, q);
    set(q, 'FaceColor', 'blue', 'EdgeColor', 'none');

    text(x(1), y(1) + (k-0.5)*offsetY, z(end), sprintf('t=%d', t), ...
         'HorizontalAlignment','center','FontSize',10,'Color',[0.1 0.1 0.1]);
end

daspect([1 1 1]); axis vis3d
view(3); camlight; lighting gouraud

% ----扩展y轴范围----
ymargin = 0.05*Ly;
ylim([y(1)-ymargin, y(end) + (numel(times)-1)*offsetY + ymargin]);
xlim([x(1), x(end)]);
zlim([z(1), z(end)]);

title('Isosurfaces shifted along +Y');
xlabel('x'); ylabel('y'); zlabel('z');
hold off;
