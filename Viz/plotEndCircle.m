function plotEndCircle(point,direction,diameter,faces)
    arguments
        point (1,3) double
        direction (1,3) double
        diameter (1,1) double
        faces (1,1) double = 27
    end

    hold on;

    t=linspace(0,2*pi,faces);
    X=(diameter/2)*sin(t);
    Y=(diameter/2)*cos(t);
    Z=zeros(1,faces); % flat circle at origin

    % rotation & transform using helper.getRz
    Rz = getRz(direction);
    points=[X',Y',Z'];
    points1=points/(Rz);

    X=((points1(:,1))+point(1))';
    Y=((points1(:,2))+point(2))';
    Z=((points1(:,3))+point(3))';

    plot3(X,Y,Z,'k-','LineWidth',1, 'HandleVisibility','off');
end