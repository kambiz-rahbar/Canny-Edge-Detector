function Y = shiftmatrix(X,shiftdir)

if size(X,1)<=shiftdir(1) || size(X,2)<=shiftdir(2)
    Y = zeros(size(X));
else 
    Y = circshift(X,shiftdir(1),1);
    Y = circshift(Y,shiftdir(2),2);
    
    if (shiftdir(1)>0)
        Y(1:shiftdir(1),:) = 0;
    elseif (shiftdir(1)<0)
        Y(end+shiftdir(1)+1:end,:) = 0;
    end
    
    if (shiftdir(2)>0)
        Y(:,1:shiftdir(2)) = 0;
    elseif (shiftdir(2)<0)
        Y(:,end+shiftdir(2)+1:end) = 0;
    end 
end