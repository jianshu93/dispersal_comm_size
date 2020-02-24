function bc=betaBetween(rep,gen,im)

% runs the model (model10A2) for different dispersals and computes the mean
% bray-curtis similarity between different runs 

% gen=60;
% a=[0 0.05 0.1 0.2:0.2:1];
% a=[0:0.01:0.05];
a=[0 0.1 0.5 1];
% a=[0 0.05 0.1 0.2:0.2:1];



bc=zeros(length(a),rep);

for j=1:rep
    disp(j);
    for i=1:length(a)
        M1=model10A2(gen,0,a(i),im);
        M2=model10A2(gen,0,a(i),im);
        bc(i,j)=brayCurt(M1,M2);

    end
end
    
mn=mean(bc,2);
se=(std(bc')/sqrt(rep))';


close all;
figure();
errorbar(a',mn,se,'ko-','markersize',10);
xlabel('Dispersal','fontsize',20);
ylabel('Similarity (BC)','fontsize',20);
xlim([min(a)-0.05 max(a)+0.05]);

beep();

%-------------------------------------------------------
function bc=brayCurt(M1,M2)

nom=2*sum(min([M1; M2]));
denom=sum(sum([M1; M2]));
bc=(nom/denom);




