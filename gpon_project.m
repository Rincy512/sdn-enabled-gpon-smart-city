clear; close all; clc;

%% ======================================================
% Offered Load
%% ======================================================
offered_load = 50:50:1000;
norm_load = offered_load / max(offered_load);

%% ======================================================
% 1️⃣ THROUGHPUT MODELS
%% ======================================================

% Conventional GPON
thr_conv = 180 * norm_load .* exp(-0.0008*offered_load);

% QoS-Aware GPON
thr_qos = 240 * norm_load .* exp(-0.0005*offered_load);

% SDN-Enabled QoS GPON
thr_sdn = 300 * norm_load .* exp(-0.0002*offered_load);

figure;
plot(offered_load,thr_conv,'k--','LineWidth',1.8); hold on;
plot(offered_load,thr_qos,'b','LineWidth',2);
plot(offered_load,thr_sdn,'r','LineWidth',2.2);
xlabel('Offered Load (Mbps)');
ylabel('Throughput (Mbps)');
title('Throughput Comparison');
legend('Conventional GPON','QoS-GPON','SDN-QoS-GPON','Location','NorthWest');
grid on;

%% ======================================================
% 2️⃣ LATENCY MODELS
%% ======================================================

lat_conv = 5 + 0.02*offered_load;
lat_qos  = 3 + 0.01*offered_load;
lat_sdn  = 1.5 + 0.006*offered_load;

figure;
plot(offered_load,lat_conv,'k--','LineWidth',1.8); hold on;
plot(offered_load,lat_qos,'b','LineWidth',2);
plot(offered_load,lat_sdn,'r','LineWidth',2.2);
xlabel('Offered Load (Mbps)');
ylabel('Latency (ms)');
title('Latency Comparison');
legend('Conventional GPON','QoS-GPON','SDN-QoS-GPON');
grid on;

%% ======================================================
% 3️⃣ PACKET DELIVERY RATIO (PDR)
%% ======================================================

loss_conv = 0.00015 * max(offered_load-300,0).^2;
loss_qos  = 0.00009 * max(offered_load-450,0).^2;
loss_sdn  = 0.00004 * max(offered_load-650,0).^2;

PDR_conv = max(min(1-loss_conv,1),0);
PDR_qos  = max(min(1-loss_qos,1),0);
PDR_sdn  = max(min(1-loss_sdn,1),0);

figure;
plot(offered_load,PDR_conv,'k--','LineWidth',1.8); hold on;
plot(offered_load,PDR_qos,'b','LineWidth',2);
plot(offered_load,PDR_sdn,'r','LineWidth',2.2);
xlabel('Offered Load (Mbps)');
ylabel('Packet Delivery Ratio');
title('PDR Comparison');
legend('Conventional GPON','QoS-GPON','SDN-QoS-GPON','Location','SouthWest');
ylim([0 1.05]);
grid on;

%% ======================================================
% 4️⃣ JITTER MODELS
%% ======================================================

jit_conv = 1 + 0.01*offered_load;
jit_qos  = 0.6 + 0.006*offered_load;
jit_sdn  = 0.3 + 0.003*offered_load;

figure;
plot(offered_load,jit_conv,'k--','LineWidth',1.8); hold on;
plot(offered_load,jit_qos,'b','LineWidth',2);
plot(offered_load,jit_sdn,'r','LineWidth',2.2);
xlabel('Offered Load (Mbps)');
ylabel('Jitter (ms)');
title('Jitter Comparison');
legend('Conventional GPON','QoS-GPON','SDN-QoS-GPON');
grid on;

%% ======================================================
% 5️⃣ Bandwidth Utilization Efficiency
%% ======================================================

eff_conv = thr_conv ./ offered_load;
eff_qos  = thr_qos  ./ offered_load;
eff_sdn  = thr_sdn  ./ offered_load;

figure;
plot(offered_load,eff_conv,'k--','LineWidth',1.8); hold on;
plot(offered_load,eff_qos,'b','LineWidth',2);
plot(offered_load,eff_sdn,'r','LineWidth',2.2);
xlabel('Offered Load (Mbps)');
ylabel('Bandwidth Utilization Efficiency');
title('Bandwidth Utilization Comparison');
legend('Conventional GPON','QoS-GPON','SDN-QoS-GPON');
grid on;

%% ======================================================
% 6️⃣ SDN-BASED DYNAMIC DBA (CORE CONTRIBUTION)
%% ======================================================

num_onu = 16;
time_slots = 100;

% synthetic ONU demand
onu_demand = abs(200 + 80*randn(num_onu,time_slots));

% SDN priority weights
w_crit = 0.5;
w_rt   = 0.3;
w_be   = 0.2;

total_bandwidth = 1000; % Mbps

alloc_crit = zeros(1,time_slots);
alloc_rt   = zeros(1,time_slots);
alloc_be   = zeros(1,time_slots);

for t = 1:time_slots
    
    demand_mean = mean(onu_demand(:,t));
    
    demand_crit = demand_mean * 0.3;
    demand_rt   = demand_mean * 0.4;
    demand_be   = demand_mean * 0.3;
    
    total_weight = w_crit*demand_crit + ...
                   w_rt*demand_rt + ...
                   w_be*demand_be;
    
    alloc_crit(t) = total_bandwidth * (w_crit*demand_crit) / total_weight;
    alloc_rt(t)   = total_bandwidth * (w_rt*demand_rt) / total_weight;
    alloc_be(t)   = total_bandwidth * (w_be*demand_be) / total_weight;
end

figure;
area(1:time_slots,[alloc_crit;alloc_rt;alloc_be]');
xlabel('Time Slots');
ylabel('Allocated Bandwidth (Mbps)');
title('SDN Intelligent Dynamic Bandwidth Allocation');
legend('Critical','Real-time','Best-effort');
grid on;

%% ======================================================
% 7️⃣ PAYLOAD IMPACT COMPARISON
%% ======================================================

payload_size = 64:64:1500;
payload_eff = 0.7 + 0.3*(payload_size/max(payload_size));

thr_payload_conv = 180 * payload_eff;
thr_payload_qos  = 240 * payload_eff;
thr_payload_sdn  = 300 * payload_eff;

figure;
plot(payload_size,thr_payload_conv,'k--','LineWidth',1.8); hold on;
plot(payload_size,thr_payload_qos,'b','LineWidth',2);
plot(payload_size,thr_payload_sdn,'r','LineWidth',2.2);
xlabel('Payload Size (Bytes)');
ylabel('Throughput (Mbps)');
title('Payload Size Impact Comparison');
legend('Conventional GPON','QoS-GPON','SDN-QoS-GPON','Location','NorthWest');
grid on;

%% ======================================================
% 8️⃣ CDF OF PACKET DELAY COMPARISON
%% ======================================================

rng(1); % reproducibility

delay_conv = abs(8 + 2.5*randn(1,4000));
delay_qos  = abs(5 + 1.8*randn(1,4000));
delay_sdn  = abs(3 + 1.2*randn(1,4000));

[f1,x1] = ecdf(delay_conv);
[f2,x2] = ecdf(delay_qos);
[f3,x3] = ecdf(delay_sdn);

figure;
plot(x1,f1,'k--','LineWidth',1.8); hold on;
plot(x2,f2,'b','LineWidth',2);
plot(x3,f3,'r','LineWidth',2.2);
xlabel('Packet Delay (ms)');
ylabel('CDF');
title('CDF of Packet Delay Comparison');
legend('Conventional GPON','QoS-GPON','SDN-QoS-GPON','Location','SouthEast');
grid on;