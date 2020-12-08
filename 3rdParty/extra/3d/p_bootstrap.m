    % get p value
    D1 = {D_child_1v2 D_child_2v3 D_child_1v2 D_adult_1v2};
    D2 = {D_adult_1v2 D_adult_2v3 D_child_2v3 D_adult_2v3};
    isPaired = [false false true true];
    for i = 1:length(D1)
        d1 = D1{i};
        d2 = D2{i};
        bootstrapStat = nan(N_BOOTSTRP,1);
        for k=1:N_BOOTSTRP
            % paired samples
            n = size(d1,1);
            idx1 = ceil(rand(size(d1,1),1)*n);
            sampD1 = d1(idx1);
            if isPaired(i)
                idx2 = idx1;
            else
                n = size(d2,1);
                idx2 = ceil(rand(n,1)*n);
            end
            sampD2 = d2(idx2);
            bootstrapStat(k) = CRfunc(sampD1) - CRfunc(sampD2);
        end
        observedSign = sign(CRfunc(d1)-CRfunc(d2));
        m = sign(bootstrapStat)==observedSign;
        %p = min((1-mean(m))*2,1)
        p = min((1-mean(m)),1) %#ok 1-tailed
    end