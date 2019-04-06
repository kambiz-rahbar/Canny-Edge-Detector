function Y = neighbors(X)

Y(:,:,1) = shiftmatrix(X,[-1,0]);
Y(:,:,2) = shiftmatrix(X,[1,0]);
Y(:,:,3) = shiftmatrix(X,[0,1]);
Y(:,:,4) = shiftmatrix(X,[0,-1]);
Y(:,:,5) = shiftmatrix(X,[0,1]);
Y(:,:,6) = shiftmatrix(X,[0,-1]);
Y(:,:,7) = shiftmatrix(X,[0,1]);
Y(:,:,8) = shiftmatrix(X,[0,-1]);