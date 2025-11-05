data = readmatrix('coords.txt');
datanew = data(data(:,3) == -2.21692 , :);
slice_X = datanew(datanew(:,2) == -2.51692 , :);
slice_X = sortrows(slice_X, 1);
[~, idx] = unique(slice_X(:,1));
duplicates = slice_X(setdiff(1:end, idx), :);
diffs_X = diff(slice_X(:,1));
plot(1:401,diffs_X);
data_unique = unique(data, 'rows');

data = readmatrix('coords.txt');

x0 = -6.06209;
y0 = -2.51692;   % 你之前用的 y
z0 = -2.21692;   % 你之前用的 z
tol = 1e-8;

% slice_Y：固定 x=x0, z=z0，按 y 排序
slice_Y = data( abs(data(:,1)-x0)<tol & abs(data(:,3)-z0)<tol, : );
slice_Y = sortrows(slice_Y, 2);

% slice_Z：固定 x=x0, y=y0，按 z 排序
slice_Z = data( abs(data(:,1)-x0)<tol & abs(data(:,2)-y0)<tol, : );
slice_Z = sortrows(slice_Z, 3);

diffs_Y = diff(slice_Y(:,2));
plot(1:131,diffs_Y);
diffs_Z = diff(slice_Z(:,3));
plot(1:131,diffs_Z);