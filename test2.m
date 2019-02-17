% test 2

% je dois couper les séquences en fonction de si fasttrack réassigne un
% numéro de poisson déjà assigner avant
% Mais je dois faire attention si un poisson "clignote"

% poisson qui clignote

% clearvars -except xbody ybody file path
close all
clc

f = 1 + 0;

cx = xbody(f,:);
cy = ybody(f,:);
% plot(cx)
% hold on
% plot(cy)

fxy = find(isnan(cx)==1);
d = diff(fxy);
ff = find(d > 1);
ind_no_object = find(diff(ff) > 10);
for i = 1:in

% determine moment when no fish are attributed



% % je corrige les problèmes de "clignotements"
% for i = 1:size(ff,2)-1
%     if ff(i)-1 == 0
%         gp = fxy(ff(i))
%     else
%         gp = [fxy(ff(i)-1),(fxy(ff(i)))]
%         dgp = diff(gp);
%         fgp = find(dgp > 1);
%         if isempty(fgp)==0
%             for j = 1:size(fgp,2)
%                 cx(gp) = (cx(min(gp)-1)+cx(max(gp)+1))/2;
%                 cy(gp) = (cy(min(gp)-1)+cy(max(gp)+1))/2;
%             end
%         elseif size(gp,2) == 1
%             cx(gp) = (cx(gp-1)+cx(gp+1))/2;
%         end
%     end
% end
% figure(1)
% plot(cx-100)
% plot(cy-100)

