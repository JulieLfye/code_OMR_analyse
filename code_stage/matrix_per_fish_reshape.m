function [matrix]=matrix_per_fish_reshape(matrix,data_to_add,nb_fish)
%% Comments
% Add nan to the short line to create a matrix with all the data, where one
% line is one subject (here fish)
%Inputs -----
% matrix: the matrix which contains all the data
% data_tot_add: the data libne to add
% nb_fish: line number
%Outputs -----
% matrix: the matrix which contains all the data, with the added line

%% Code
[m1,m2] = size(matrix);
l2 = size(data_to_add,2);
if l2 == 1
    data_to_add = data_to_add';
    l2 = size(data_to_add,2);
end

if l2 == m2
    matrix(nb_fish,:) = data_to_add;
elseif l2 < m2
    matrix(nb_fish,:) = [data_to_add, nan(1,m2-l2)];
elseif l2 > m2
    mat = [matrix(:,1:m2), nan(m1,l2-m2); data_to_add];
    matrix = mat;
end
