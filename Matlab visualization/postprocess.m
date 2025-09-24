n = 7004448;
folder = 'C:\Users\28027\Desktop\Flow_Field\FlowField0.5\snapshots\';
c = readmatrix(fullfile(folder,'coords.txt'));                 % [n×3], columns: x y z
Vfield = readmatrix(fullfile(folder,'Valve_0.5mm_Snapshot_0015.txt'));

vx = Vfield(1:n,1);
vy = Vfield(n+1:2*n,1);
vz = Vfield(2*n+1:3*n,1);


x = unique(c(:,1));  nx = numel(x);
y = unique(c(:,2));  ny = numel(y);
z = unique(c(:,3));  nz = numel(z);

[~,ix] = ismember(c(:,1), x);
[~,iy] = ismember(c(:,2), y);
[~,iz] = ismember(c(:,3), z);

lin = sub2ind([ny,nx,nz], iy, ix, iz);

Vx = nan(ny,nx,nz); Vy = Vx; Vz = Vx;
Vx(lin) = vx;
Vy(lin) = vy;
Vz(lin) = vz;

[X,Y,Z] = meshgrid(x, y, z);

[curlx, curly, curlz, cav] = curl(X, Y, Z, Vx, Vy, Vz);

sum = sqrt(curlx.^2+curly.^2+curlz.^2);
omegaMag = curlx;
contourNum = 1.8;

p = patch(isosurface(X, Y, Z, omegaMag, contourNum));
isonormals(X, Y, Z, omegaMag, p)
p.FaceColor = 'red';
p.EdgeColor = 'none';
hold on;

q = patch(isosurface(X, Y, Z, omegaMag, -contourNum));
isonormals(X, Y, Z, omegaMag, p)
q.FaceColor = 'blue';
q.EdgeColor = 'none';

daspect([1 1 1])
camlight; lighting gouraud
