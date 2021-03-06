function outH = HGrandom2(inputm,inputn)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%--------- 用Mackay方法产生(3,6)的校验矩阵H(m*n) ----------%%%
%%%--------------- 其中保证 dv=3，n=2*m -----------------------%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%------------ 第1步 初始化部分参数，H的维数 ------------------%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
m = inputm;
n = inputn;
dv = 3;% 最大列重
dc = 6;% 最大行重
j = 1;
Ha = zeros(m,m);
H = zeros(m,n);
firstcolumn = zeros(m,1);
flag = 0;% 是否有圈的判决位,1为有圈,0为无圈
flag2 = 0;% 是否有圈的判决位,1为有圈,0为无圈
countnumber = 1;% 记录分配在各列中1的个数

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%------------ 第2步 假设H=[Ha|Hb]，先构造Ha(m*m) ------------%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%% 2-1 先设计Ha的第一列，保证列重为dv，且保证通过行循环移 %%%%%%%
%%%%%%%%%%% 位产生的下一列与之前各列没有圈为4的环%%%%%%%%%%%%%%%%%%

H(1,1) = 1;% 固定使H(1,1)为1

rpa = random('unid',m-1,1) + 1;% random('unid',m-1,1)产生一个1到m-1的随机数，“+1”的目的是实现在第一列的2到m行中随机选一行
H(rpa,1) = 1;
mid = find(H(:,1)==0); % mid记录了第一列除去第一行、第rpa行后余下的为零的行
while j <= length(mid)
rpa2 = random('unid',m-2,1);% 在剩下的m-2行中随机选择某一个位置添加1
        H(mid(rpa2),1) = 1;        
        Ha(:,1) = H(:,1);
        for i = 2:m% 该循环的作用是以第一列为基础，Ha的第2到m列都是前一列通过行循环移位得到的
            upperpart = Ha(m,i-1);
            lowerpart = Ha(1:m-1,i-1);
            Ha(:,i) = [upperpart;lowerpart];
        end;    
        
        ssa=Ha(:,1);
        ssb=Ha(:,2:m);
        ssc=[ssa,ssb];
        
        flag = checkloop(Ha);% tellloop为子程序，判决是否有度为4的圈，flag = 1表示有，反之无
        if flag == 0
            break;% 没有环，说明生成的Ha矩阵符合标准，完成Ha部分的生成      
        else
            H(mid(rpa2),1) = 0;% 有环，说明在第1列rpa2行添加1产生的基础列不能满足无圈的要求，将第1列rpa2行重置为0，继续while循环
        end;
j = j + 1;
end;
    
H(:,1:m) = Ha;% 固定H左半部分不再变化

% 使用JC译码算法
% 若直接使H = [Ha Ha]的方法构造，确实可以保证m行里每两行存在圈，
% 譬如(1,3),(2,4),(5,7),(6,8)...(m-3,m-1)，(m-2,m)都是有圈的环
% 不过该H,H=[Ha Ha],进行高斯消元后只会得到一个等于
% [eye(n-m,n-m) eye(n-m,n-m)]的生成矩阵G,不知这是否还满足LDPC的编码


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%---- 第3步 尝试构造Hb(m*m)，保证列重为dv且没有度为4的圈 -----%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%% 3-1 先在第m+1列生成一列合适的向量，保证与H的第1到m列 %%%%%%
%%%%%%%%%%%%%%%%%%%%%%% 没有度为4的圈 %%%%%%%%%%%%%%%%%%%%%%%%%%%
i = 1+m;
rpa = random('unid',m,1);% 在第m+1列,即firstcolumn中任取一行添加1
firstcolumn(rpa,1) = 1;
while flag2 == 0
    while countnumber <= dv
        mid = find(firstcolumn == 0);
        rpa2 = random('unid',length(mid),1);%在剩下的m-1行中随机选择一行添加1
        firstcolumn(mid(rpa2),1) = 1;
        flag = tellloop(firstcolumn,Ha);%嵌入程序，判决与H的第1到m行，是否有度为4的圈，flag = 1表示有，反之无        
        if flag == 0
            countnumber = countnumber+1;% 没有环,则说明在第rpa2行添加的1不会引起度为4的圈,保留该行的设置并对计数位加1
            if countnumber == dv% 保证添加的1的总个数为列重dv,当该列添加的1的个数为dv时,跳出设置Hb基础列的循环
               countnumber = dv+1;
            end;
        else
            firstcolumn(mid(rpa2),1) = 0;% 有环,将第rpa2行复位,循环
        end;
    end;
    
%%%%%%%%%%%% 3-2 通过对第m+1列的基础列向量做行循环移位，产生Hb %%%%%%%%%%%%%

Hb(:,1) = firstcolumn;
for i = 2:m
    upperpart = Hb(m,i-1);
    lowerpart = Hb(1:m-1,i-1);
    Hb(:,i) = [upperpart;lowerpart];
end;

flag2 = tellloop(firstcolumn,Hb(:,2:m));
%嵌入程序，判决Hb是否存在度为4的圈，flag = 1表示有，反之无
%因为可能出现Hb(:,1)=[1 0 1 0 1 0 0 ....]的情况，此时Hb(:,1)与Ha没有环，但是与自身存在环，因此必须避免
    if flag2 == 0
        flag2 = 1;% 没有环，构造的Hb符合条件，跳出构造Hb的循环
    else
        firstcolumn = 0;% 有环，则将firstcolumn复位
        firstcolumn(rpa,1) = 1;% 重新将firstcolumn(rpa,1)设置为1
        flag2 = 0;% 重置循环控制变量flag2=0,保证Hb循环继续
    end;
end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%---------------- 第4步 输出需要的校验矩阵H -----------------%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
H(:,1+m:n) = Hb;

outH = H;