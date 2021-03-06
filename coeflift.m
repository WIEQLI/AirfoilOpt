function cl = coeflift(naca,alpha)
clc
%
%specify inlet conditions
%
%alpha=10; %in degrees
npanel=100; %total number of panels on the airfoil surface 
%
% allocate all necessary arrays
%

x  = zeros(npanel+1,1);
y  = zeros(npanel+1,1);
cp = zeros(npanel+1,1);

%
% generate airfoil surface panelization
%

[x,y] = naca4(naca,npanel,x,y);

%
% generate panel geometry data for later use
%

l    = zeros(npanel,1);
st   = zeros(npanel,1);
ct   = zeros(npanel,1);
xbar = zeros(npanel,1);
ybar = zeros(npanel,1);

[l,st,ct,xbar,ybar] = panel_geometry(x,y,npanel);

%
% compute matrix of aerodynamic influence coefficients
%

ainfl = zeros(npanel+1);

ainfl = infl_coeff(x,y,xbar,ybar,st,ct,ainfl,npanel);
%ainfl
%
% compute right hand side vector for the specified angle of attack
%

b  = zeros(npanel+1,1);

al = alpha * pi / 180;

for i=1:npanel
    b(i) = st(i)*cos(al) -sin(al)*ct(i);
end

b(npanel+1) = -(ct(1)     *cos(al) +st(1)     *sin(al)) ...
              -(ct(npanel)*cos(al) +st(npanel)*sin(al));
         
%
% solve matrix system for vector of q_i and gamma
%

qg = inv(ainfl) * b;

%
% compute the tangential velocity distribution at the midpoint of panels
%

vt = veldis(qg,x,y,xbar,ybar,st,ct,al,npanel);


%
% compute pressure coefficient
%

cp = 1 -vt.^2;
%mincp=min(cp)
%
% compute force coefficients
%

[cl,cd] = aero_coeff(x,y,cp,al,npanel);

%
% plot the output
%

%subplot(2,1,1),plot(xbar,-cp),xlabel('x/c'),ylabel('Cp'),title('Coefficient of Pressure Distribution'),grid

%subplot(2,1,2),plot(x,y,x,y,'o'),xlabel('x/c'),ylabel('y/c'),title('Airfoil Geometry'),axis('equal'),grid
%lbyd=-cl/cd;
return
