function Mf=model10A2(gen,pt,a,im)

% runs the stochastic homogenous model with dispersal rate a

% gen - no. generations to run
% pt - plot time/richness graph? (0 - no, 1 - yes)
% a - dispersal level (0<a<1)
% im - immigration rate (individuals per generation)
% Mf - metacommunity composition after gen generations

%--------------parameters----------------------
dif=2; % max/min (1=neutral)
isgraded=1; %if==1 > x=[dif dif-delta....1]; if==0 > x=[dif 1 1 1...1];  
iskadmon=1; % dispersal mode = is global? (1=Kadmon,0=Mouquet/loreau)
N=8; % no. communities
S=100; % no. spp.
jj=2;%100/S; % factor for community size (j=jj*S)
m=1; %proportion of mortality 
% im=2; %no. immigrants from mainland per gen. to metacom
r=3; %minimum r (groth rate)
% domnum=10; 

% a=1.3.^([0:10]); 
% a=a-min(a);
% a=a/max(a); % dispersal rates
% a=[0:0.1:1];
% a=[0 0.05 0.1 0.2:0.2:1];
%---------------------------------------------

% pars=[dif isgraded iskadmon N S jj m im r gen]';

stead=gen; % generations to steady state
gen=round(gen+10); %generations after steady state(for computation)

M=floor(jj)*ones(N,S); %initial metacom.
rm=rem(jj*S,S);
M(:,1:rm)=M(:,1:rm)+ones(N,rm);

% M=zeros(N,S);
% M(:,1)=jj*S*ones(N,1);


% M
% return

if pt==1
    a=0;
    gen=stead;
end

imv=zeros(1,gen);

if im==0||im>=1 
    imv=im*ones(1,gen);
elseif im<1 && im>0
    t=[zeros(1,1/im-1) 1];
    t=repmat(t,1,round(gen/length(t))+10);
    imv=t(1:gen);
end


if dif==1
    x=r*ones(1,S);
else
    x=r*(dif:-(dif-1)/(S-1):1);
end

if isgraded==0
    x=r*[dif ones(1,S-1)];
elseif isgraded>1
    x=r*((dif-1)*((1:-1/(S-1):0).^isgraded)+1);
end

% x=r*ones(1,S);
% x(1:domnum)=r*dif*ones(1,domnum);

% elseif isgraded~=0 && isgraded~=1
%     x=r*dif*(((dif:-(dif-1)/(S-1):1)/dif).^isgraded);
% end

repro=ones(N,1)*x;

alpha=zeros(length(a),gen+1);
% beta=zeros(length(a),gen+1);
gamma=zeros(length(a),gen+1);
% comp=zeros(length(a),gen+1); % compositional compatability
% % sync=zeros(length(a),1); %mean syncrony between timeseries of all spp.
% Time=zeros(length(a),1,S); %mean spp. survival time
% dist=zeros(length(a),1,S); %mean abundance distribution from gen=1 to gen/2
% sing=zeros(length(a),1,S); %mean ext. prob. for each sp. and dispersal
% exti=zeros(length(a),1);

for i=1:length(a) 
   
%     [rich,t,d,si,ex,Mf]=manyGenerations(M,a(i),imv,repro,m,iskadmon,gen,stead);
    [rich,Mf]=manyGenerations(M,a(i),imv,repro,m,iskadmon,gen,stead);
    
    alpha(i,:)=rich(1,:);
%     beta(i,:)=rich(2,:);
    gamma(i,:)=rich(3,:);
%     comp(i,:)=rich(4,:);    
% %     sync(i)=s;
%     Time(i,:,:)=t;
%     dist(i,:,:)=d;
%     sing(i,:,:)=si;
%     exti(i)=ex;
end

if pt==1
    close all
    plot((0:gen),gamma(1,:),(0:gen),alpha(1,:));
end

legend('gamma','alpha');
xlabel('generations');
ylabel('richness');


% alpha=mean(alpha(:,stead:end),2);
% beta=mean(beta(:,stead:end),2);
% gamma=mean(gamma(:,stead:end),2);
% comp=mean(comp(:,stead:end),2);

% plot((0:gen),alpha(3,:));
% y=mean(alpha(:,1000:end),2)';
% plot(a,y,'ko','MarkerFaceColor',[0 0 0]);
% xlim([-0.1 1.1]);

%---------------------------------------------------
function [rich,Mf]=manyGenerations(M,a,im,repro,m,dm,gen,stead)

%[rich,surv,dist,sing,exti,Mf]=manyGenerations(M,a,im,repro,m,dm,gen,stead)

% runs the model for gen no. generations

%a=proportion of immigrants from other communities
%im=proportion of immigrants from continent
%x=a row of spp. traits
%a+im<=1
%dif=interval of x (spp. traits) 0=neutral, 1='full' differential
%het=is heterogenous?
%m=mortality
%r=factor of reproduction
%gen=no. generations

% sum(sum(M))

[N,S]=size(M);
z=compos(M,repro);
rich=[[S 0 S z]' zeros(4,gen)];

MM=zeros(N,S,gen+1);
MM(:,:,1)=M;
% sin=0;
% ext=0;

for i=1:gen    
    M=oneGeneration(M,a,im(i),repro,m,dm);
    gamma=nnz(sum(M));
    alpha=nnz(M)/N;
    beta=gamma-alpha;
%     z=compos(M,repro);
    rich(:,i+1)=[alpha beta gamma z]';
    MM(:,:,i+1)=M;
%     if i>stead
%         sin=sin+si;
%         ext=ext+ex;
%     end
end

% coher=coherence(MM);
% coher=coherence(MM(:,:,stead:end));
% surv=survival(MM,stead);
% dist=abundDist(MM,stead);
% sing=singleton(MM,stead);
% exti=ext/sin;

Mf=sum(sum(MM(:,:,stead:end),3),1); % metacommunity
% Mf=sum(sum(MM(1,:,stead:end),3),1); % local community
%----------------------------------------------------
function Mf=oneGeneration(Mi,a,im,repro,m,dm)

%[Mf,si,ex]=oneGeneration(Mi,a,im,repro,m,dm)

% performs on cicle of each community
%a=proportion of immigrants from other communities
%im=proportion of immigrants from continent
%a+im<=1
%dif=interval of x (spp. traits) 0=neutral, 1='full' differential
%het=is heterogenous?
%m=mortality
%r=factor of reproduction



[N,S]=size(Mi); % no. communities and spp.
j=sum(sum(Mi))/N; % community size


% x=[1/N:1/N:1]*dif+(1-dif)/2; % spp. traits
% x=ones(N,1)*x;
% 
% if het==1
%     E=1/N:1/N:1; % heterogeneous patch traits
% else
%     E=0.5*ones(1,N); %homogeneous patch traits
% end
% 
% E=(ones(N,1)*E)';

Mf=Mi;

V=round(j*m); %total no. open sites (no. dead individuals)
dr=round(a*V); %no. sites for dispersing recruits
lr=V-dr; %no. sites for local recruits 



% repro=(1-abs(E-x))*r; % a matrix of groth rate for each sp. in each com.

%---------reproduction------------------------

B=Mi.*repro; % a pool of potential local and dispersing recruits
B(B<0)=0;
B=round(B);

%----------mortality--------------------------
if m<1
    for k=1:N
        l=lineVec(Mf(k,:)); % line of column (sp.) numbers
        l=l(randperm(length(l)));    
        l=l(1:V); % random V individuals to die
        ab=hist(l,(1:S));
        Mf(k,:)=Mf(k,:)-ab; 
    end
else
    Mf=zeros(size(Mi));
end

%---------local recruitment-------------------

if lr>0
    for k=1:N      
        l=lineVec(B(k,:)); % line of column (sp.) numbers
        l=l(randperm(length(l)));
        l=l(1:lr);
        ab=hist(l,(1:S));
        Mf(k,:)=Mf(k,:)+ab; % adding local recruitments
        B(k,:)=B(k,:)-ab; % subtracting local recruitments from pool of new borns
    end
end

%--------dispersal from other communities ------

if dr>0 && dm==0 % Mouquet&Loreau 
    
    for k=1:N
        T=B;
        T(k,:)=zeros(1,S);
        l=lineMat(T); % line of row & column (sp.) numbers        
        l=l(:,randperm(size(l,2)));
        d=matLine(l(:,1:dr),N,S); %matrix of dispersed recruits            
        B=B-d; %subtracting the dispersed individuals       
        Mf(k,:)=Mf(k,:)+sum(d); % adding dispersal recruitments    
    end     
    
elseif dr>0 && dm==1 %Kadmon
    tot=sum(B);

    for k=1:N 
        
        l=lineVec(tot); % line of column (sp.) numbers
        l=l(:,randperm(length(l)));        
        l=l(1:dr);
        ab=hist(l,(1:S));       
        Mf(k,:)=Mf(k,:)+ab; % adding dispersal recruitments    
        tot=tot-ab;
    end 
    
end


% si=sum(Mi)==1; %all singletons
% ex=sum(Mf);
% ex=(si==1&ex==0); %all singleton extinctions
% 
% si=sum(si);
% ex=sum(ex);


%--------dispersal from mainland-----------------------

if im>0
    l=lineVec(im*ones(1,S)); % line of column (sp.) numbers of mainland pool
    l=l(randperm(length(l)));  
    for i=1:im
        row=randi(N,1); % com. to do swap
        ll=lineVec(Mf(row,:));
        ll=ll(randperm(length(ll)));
        col1=ll(1); % sp. to do kill
        col2=l(i); %sp. to ad
        Mf(row,col1)=Mf(row,col1)-1; %         
        Mf(row,col2)=Mf(row,col2)+1; % adding dispersal recruitments  
    end 
end

%-----------------------------------------------------
function l=lineVec(A)

%transforms abundance vector into line of column (sp.) numbers

l=[];

for i=1:length(A)
    l=[l i*ones(1,A(i))];
end

%----------------------------------------------------------
function d=matLine(l,N,S);

% gets a line of rows and columns and transforms then
% to a N*N matrix

n=size(l,2);
d=zeros(N,S);

for j=1:n
    d(l(1,j),l(2,j))=d(l(1,j),l(2,j))+1;
end
    
%--------------------------------------------------------
function l=lineMat(A)

%transforms abundance matrix into a line of row & column (sp.) numbers

[m,n]=size(A);

l=[];

for i=1:m
    for j=1:n
        l=[l [i*ones(1,A(i,j)); j*ones(1,A(i,j))]];
    end
end

%-------------------------------------------------------
function z=compos(M,repro);

m=sum(M)/sum(sum(M));
r=repro(1,:);
r=r-min(r);

if max(r)>0
    r=r/max(r);
end

z=dot(m,r');

%------------------------------------------------------
% function c=coherence(M)
% 
% n=size(M,2);
% c=[];
% 
% M=shiftdim(M,2);
% 
% for i=1:n
%     
%     M(:,:,i);
%     t=corr(M(:,:,i));
%     t=triu(t,1);
%     t=nanmean(nonzeros(t));
%     c=[c t];
% end
% c=nanmean(c);

%------------------------------------------------------
% function surv=survival1(M);
% 
% % mean survival time for all species
% 
% n=size(M,2); %no. spp.
% M=sum(M);
% M=shiftdim(M,2);
% M(M>0)=1;
% 
% V=[];
% 
% for i=1:n
%     V=[V; 0; M(:,:,i)];
% end
% 
% 
% B=[0; V==1; 0];
% C = find(diff(B)==-1)-find(diff(B)==1);
% seq=length(C); %no. sequences
% tot=sum(V); %total length of sequences
% 
% surv=tot/seq; %mean length of sequences of all spp.
%------------------------------------------------------
function surv=survival(M,stead);


% survival time for each species

M=M(:,:,stead:end); %steady state
% M=M(:,:,1:stead); %transient

[n,s,g]=size(M); %no. spp.
M=sum(M);
M=shiftdim(M,2);
M(M>0)=1;
M=[zeros(1,1,s);M];
surv=zeros(1,1,s);

for sp=1:s
    v=M(:,:,sp);
    c=find(diff(v)==1);
    seq=length(c);
    tot=sum(v);
    surv(1,1,sp)=tot/seq;
end
  
%--------------------------------------------------------------
% function dist=abundDist1(MM,stead);
% 
% %computes mean cv of pop sizes in all communities
% 
% 
% [n,s,g]=size(MM);
% gg=round(stead/2);
% j=sum(MM(1,:,1));
% % M=MM(:,:,2:gg); %transient cv
% M=MM(:,:,stead:g); %steady-state cv
% % M=MM; %all time scale
% g=size(M,3);
% 
% cv=zeros(g,1);
% 
% for gen=1:g
%     sm=sum(M(:,:,gen));
%     t=M(:,sm~=0,gen);
%     sd=std(t);
%     mn=mean(t);
%     y=mean(sd./mn);
%     cv(gen)=y;
% end
% 
% dist=mean(cv);
%--------------------------------------------------------------
function dist=abundDist(MM,stead);

%computes mean cv of pop sizes in all communities


[n,s,g]=size(MM);
gg=round(stead/2);
j=sum(MM(1,:,1));
% M=MM(:,:,2:gg); %transient cv
M=MM(:,:,stead:g); %steady-state cv
% M=MM; %all time scale
[n,s,g]=size(M);

cv=nan(g,s);

for gen=1:g
    sm=sum(M(:,:,gen));
    t=M(:,sm~=0,gen); 
    sd=std(t);
    mn=mean(t);
    y=sd./mn;
   
    cv(gen,sm~=0)=y;
    
end

dist=nanmean(cv);

%---------------------------------------------
function sing=singleton(MM,stead)

%computes for each sp. and each dispersal rate the singleton extinction
%probability in one generation

M=MM(:,:,stead:end);
[N,S,g]=size(M);

on=zeros(1,S); %no. singleton generations for each sp.
ex=zeros(1,S); %no. extinctions from a state of singleton

for i=1:g-1
    Ti=sum(M(:,:,i));
    Ti(Ti~=1)=0;
    Tf=sum(M(:,:,i+1));
    ext=(Ti==1&Tf==0);
    on=on+Ti;
    ex=ex+ext;
end

sing=ex./on;
sing=reshape(sing,1,1,S);    
    
    
















    





    
    
    
    
    
    
    
    


