    
    
    pow = rand(100,1);
    
    prev_pow = pow(1);
    update_interval = 0.5;
    steps           = 0.01; 
    
    rn = 0;
    while rn < 100
        rn = rn + 1;
        smallsteps = linspace(prev_pow, pow(rn), update_interval / steps);
        for j = 1:numel(smallsteps)
        %bar(1, pow(rn), 0.1, 'b');
        bar(1, smallsteps(j), 0.1, 'b');
        axis([0.7 1.3 -0.1 1.1]);
        xlabel('8 - 12 Hz');
        ylabel('power');
        drawnow
        pause(steps);
        end
        prev_pow = pow(rn);
        %pause(0.5);
    end
    
    
    

    imagesc(zeros(50,50)+pprz); caxis([0, 100]);
    colorbar
    set(gca,'XTick',[], 'YTick', []);
    xlabel('% of max');
%     out(count)=pprz;

    str = sprintf('time = %d s\n', round(mean(data.time{1})));
    title(str);