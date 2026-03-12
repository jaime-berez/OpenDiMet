function plotEndCircle(pnt,dir,dia,faces)
    % PLOTENDCIRCLE Plot a circular cross-section oriented in 3D space.
    %
    %   Syntax
    %     plotEndCircle(pnt, dir, dia)
    %     plotEndCircle(pnt, dir, dia, faces)
    %
    %   Description
    %     Plots a circle in 3D space centered at the specified point and
    %     oriented perpendicular to the given direction vector. The circle
    %     is generated in a local XY-plane and then rotated so that its
    %     normal aligns with the specified direction.
    %
    %   Input Arguments
    %     pnt - 1x3 double - Center point of the circle.
    %     dir - 1x3 double - Direction vector defining the normal of the circle.
    %     dia - 1x1 double - Diameter of the circle.
    %     faces - 1x1 double - Number of sample points used to generate the
    %     circle. Default: 27
    %         
    %   Output
    %     This function produces a 3D plot of the circle.
    %
    %   Example
    %     p = [0 0 0];
    %     d = [0 0 1];
    %     plotEndCircle(p, d, 10);
    arguments
        pnt (1,3) double
        dir (1,3) double
        dia (1,1) double
        faces (1,1) double = 27
    end

    hold on;

    t=linspace(0,2*pi,faces);
    X=(dia/2)*sin(t);
    Y=(dia/2)*cos(t);
    Z=zeros(1,faces); % flat circle at origin

    % rotation & transform using helper.getRz
    Rz = rotMatA2Z(dir);
    pnts=[X',Y',Z'];
    points1=pnts/(Rz);

    X=((points1(:,1))+pnt(1))';
    Y=((points1(:,2))+pnt(2))';
    Z=((points1(:,3))+pnt(3))';

    plot3(X,Y,Z,'k-','LineWidth',1, 'HandleVisibility','off');
end