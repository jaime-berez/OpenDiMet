% Format the colorbar for form error figures
function formatColorBar(ax,residual,location)
    
    minR = min(residual); %minimul residual
    maxR = max(residual); %maximum residual
    N=9; %number of ticks on the colorbar
    t = linspace(0,1,N); %row of N values between 0 and 1

    if abs(maxR) > abs(minR) %if abs(maxR) is greater than abs(minR)
        tl = linspace(-abs(maxR),abs(maxR),N); %row of N values from -abs(maxR) to +abs(maxR)
        %disp('max');
    else
        tl = linspace(-abs(minR),abs(minR),N); %row of N values from -abs(minR) to +abs(minR)
        %disp('min');
    end

    c = colorbar(ax,'Ticks',t,'TickLabels',tl,'Location',location); %assign the ticks to the colorbar

end