n = 7004448;
folder = 'C:\Users\28027\Desktop\Flow_Field\FlowField0.5\snapshots\';
c = readmatrix(fullfile(folder,'coords.txt'));   % [n×3], columns: x y z

x = unique(c(:,1));  nx = numel(x);
y = unique(c(:,2));  ny = numel(y);
z = unique(c(:,3));  nz = numel(z);

[~,ix] = ismember(c(:,1), x);
[~,iy] = ismember(c(:,2), y);
[~,iz] = ismember(c(:,3), z);
lin = sub2ind([ny,nx,nz], iy, ix, iz);

[X,Y,Z] = meshgrid(x, y, z);

contourNum = 0.00075;


fname  = 'Valve_0.5mm_Avg_Mode_1.txt';
Vfield = readmatrix(fullfile(folder, fname));

vx = Vfield(1:n,1);
vy = Vfield(n+1:2*n,1);
vz = Vfield(2*n+1:3*n,1);

Vx = nan(ny,nx,nz); Vy = Vx; Vz = Vx;
Vx(lin) = vx;  Vy(lin) = vy;  Vz(lin) = vz;

[curlx, curly, curlz, ~] = curl(X, Y, Z, Vx, Vy, Vz);


%omegaMag = sqrt(curlx.^2 + curly.^2 + curlz.^2);
omegaMag = curlx;

figure; ax = axes;
p = patch(isosurface(X, Y, Z, omegaMag,  contourNum));
isonormals(X, Y, Z, omegaMag, p);
set(p, 'FaceColor', 'red',  'EdgeColor', 'none');

q = patch(isosurface(X, Y, Z, omegaMag, -contourNum));
isonormals(X, Y, Z, omegaMag, q);
set(q, 'FaceColor', 'blue', 'EdgeColor', 'none');

daspect([1 1 1]); axis vis3d tight
view(3); camlight headlight; lighting gouraud
xlim([x(1), x(end)]);
ylim([y(1), y(end)]);
zlim([z(1), z(end)]);

title('Isosurfaces of |curl(V)| at \pm threshold');
xlabel('x'); ylabel('y'); zlabel('z');
