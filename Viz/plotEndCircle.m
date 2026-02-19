function plotEndCircle(pnt,dir,dia,faces)
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
    Rz = getRz(dir);
    pnts=[X',Y',Z'];
    points1=pnts/(Rz);

    X=((points1(:,1))+pnt(1))';
    Y=((points1(:,2))+pnt(2))';
    Z=((points1(:,3))+pnt(3))';

    plot3(X,Y,Z,'k-','LineWidth',1, 'HandleVisibility','off');
end