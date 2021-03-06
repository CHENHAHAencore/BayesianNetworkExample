%
% Example of Bayesian network with discrete, binary nodes.
% Author: Marek Kendziorek (marek@kendziorek.pl)
%
%

clear all;
close all;

%% Parameters
N = 8; %number of nodes

% nodes' IDs
nodeA = 1; 
nodeB = 2; 
nodeC = 3; 
nodeD = 4;
nodeE = 5;
nodeF = 6;
nodeG = 7;
nodeH = 8;

nodeACpd = [0.99 0.01];
nodeBCpd = [0.99 0.95 0.01 0.05];
nodeCCpd = [0.5 0.5];
nodeDCpd = [0.99 0.9 0.01 0.1];
nodeECpd = [0.7 0.4 0.3 0.6];
nodeFCpd = [1 0 0 0 0 1 1 1];
nodeGCpd = [0.95 0.02 0.05 0.98];
nodeHCpd = [0.9 0.3 0.2 0.1 0.1 0.7 0.8 0.9];

%% Creating dag (direct acyclic graph)
dag = zeros(N,N); %matrix of connections
dag(nodeA,nodeB) = 1;
dag(nodeB,nodeF) = 1;
dag(nodeC,[nodeD nodeE])=1;
dag(nodeD,nodeF) = 1;
dag(nodeE,nodeH) = 1;
dag(nodeF,[nodeG nodeH]) = 1;

%% Defining nodes types and sizes (in this case all nodes are binary)
discrete_nodes = 1:N;
node_sizes = 2*ones(1,N); 

%% Creating Bayes net
onodes = []; %observed nodes - for now default value
bnet = mk_bnet(dag, node_sizes, 'discrete', discrete_nodes, 'observed', onodes);

%% Defininf CPD (Conditional Probability Distribution)
bnet.CPD{nodeA} = tabular_CPD(bnet, nodeA, nodeACpd);
bnet.CPD{nodeB} = tabular_CPD(bnet, nodeB, nodeBCpd);
bnet.CPD{nodeC} = tabular_CPD(bnet, nodeC, nodeCCpd);
bnet.CPD{nodeD} = tabular_CPD(bnet, nodeD, nodeDCpd);
bnet.CPD{nodeE} = tabular_CPD(bnet, nodeE, nodeECpd);
bnet.CPD{nodeF} = tabular_CPD(bnet, nodeF, nodeFCpd);
bnet.CPD{nodeG} = tabular_CPD(bnet, nodeG, nodeGCpd);
bnet.CPD{nodeH} = tabular_CPD(bnet, nodeH, nodeHCpd);

%% Choosing junction tree engine for inference
engine = jtree_inf_engine(bnet);

%% Defining observed evidence
evidence = cell(1,N);
%evidence{nodeD} = 2; %false = 1; true = 2; We observed that this node is true;

%specific problem definition
evidence{nodeA} = 1;
%evidence{nodeB} = 2;
evidence{nodeC} = 2;
% evidence{nodeD} = 2;
% evidence{nodeE} = 2;
% evidence{nodeF} = 2;
evidence{nodeG} = 2;
evidence{nodeH} = 1;

%% Connecting evidence and engine
[engine, loglik] = enter_evidence(engine, evidence);

%% Computing probability
marg = marginal_nodes(engine, nodeB); %We are looking for case when this node is true
pFalse = marg.T(1); %probability that it's not true
pTrue = marg.T(2) % probability that it's true