function [out] = PDEone(in,mask,q,t)
    [m,n] = size(mask);
    
    in = padarray(in,[q,q],'symmetric','both');
    mask = padarray(mask,[q,q],'symmetric','both');
    
    
    Gx = zeros(size(in));
    Gy = zeros(size(in)); 
    out = in;
    [Gx(:,:,1),Gy(:,:,1)] = imgradientxy(in(:,:,1)) ;
    [Gx(:,:,2),Gy(:,:,2)] = imgradientxy(in(:,:,2)) ;
    [Gx(:,:,3),Gy(:,:,3)] = imgradientxy(in(:,:,3)) ;
    
    [x,y] = meshgrid(-1*q:q,-1*q:q);
    
    for i = q+1:m+q   
        for j = q+1:n+q
  
            if (mask(i, j) < 1)
                continue
            end
            
            Gr = [Gx(i,j,1) * Gx(i,j,1) , Gx(i,j,1) * Gy(i,j,1)  ; Gx(i,j,1) * Gy(i,j,1) , Gy(i,j,1) * Gy(i,j,1)];
            Gg = [Gx(i,j,2) * Gx(i,j,2) , Gx(i,j,2) * Gy(i,j,2)  ; Gx(i,j,2) * Gy(i,j,2) , Gy(i,j,2) *Gy(i,j,2) ];
            Gb = [Gx(i,j,3) * Gx(i,j,3) , Gx(i,j,3) * Gy(i,j,3)  ; Gx(i,j,3) * Gy(i,j,3) , Gy(i,j,3) *Gy(i,j,3)];
            
            
            G_sigma = Gr + Gg + Gb;
            G_mask = fspecial('gaussian',3,1);
            G_sigma = imfilter(G_sigma,G_mask);
            
            [Evec,Eval] = eig(G_sigma); 
            [Eval, perm] = sort(diag(Eval), 'descend');
            Evec = Evec(:, perm);
            
            Tc = Eval(1)+Eval(2);
            T = (1/(sqrt(Tc+1)))*(Evec(:,2)*Evec(:,2)') + (1/(Tc+1))*(Evec(:,1)*Evec(:,1)');
            Td = inv(T) ;
            
            GTt =  exp(-1*(x.*x*Td(1,1)+Td(2,1)*x.*y+Td(1,2)*x.*y+Td(2,2)*y.*y)/(4*t));
            
            GTt = GTt/sum(GTt(:));
            
            neigh = in(i-q:i+q,j-q:j+q,:);
            F = (conv2(neigh(:,:,1),GTt,'same'));
            out(i,j,1) =  F(q+1,q+1);
            F = (conv2(neigh(:,:,2),GTt,'same'));
            out(i,j,2) =  F(q+1,q+1);
            F = (conv2(neigh(:,:,3),GTt,'same'));
            out(i,j,3) =  F(q+1,q+1);
             
            
        end
    end
    out = out(q+1:m+q,q+1:n+q,:);
end