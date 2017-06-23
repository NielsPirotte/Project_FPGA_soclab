A = imread('background_jonas.jpg'); %256 * 256
[n, m, c] = size(A);

%threshold = 100;

fileID = fopen('background_test_jonas.mif','wt');

%header
fprintf(fileID, '\n-- Clearbox generated Memory Initialization File (.mif)\n\n');
fprintf(fileID, 'WIDTH=2;\n');
fprintf(fileID, 'DEPTH=8704;\n\n');
fprintf(fileID, 'ADDRESS_RADIX=HEX;\nDATA_RADIX = HEX;\n\n');
fprintf(fileID, 'CONTENT BEGIN\n');

number = 0;
for i = 1:n
    for j = 1:m
        formatSpec1 = '\t%3X  :\t';
        fprintf(fileID, formatSpec1, number);
        
        r = A(i, j, 1);
        g = A(i, j, 2);
        b = A(i, j, 3);
       
        if r == 62 && g == 176 && b == 213
            v = 0;
        elseif r == 48 && g == 112 && b == 96
            v = 1;
        else
            if r == 58 && g == 183 && b == 79
                       v = 2;
            else
                v = 3;
            end
        end
             
        hex = dec2hex(v);
        formatSpec2 = '%s ;\n';
        fprintf(fileID, formatSpec2, hex);
        number = number + 1;
    end
end

%footer
fprintf(fileID,'END\n');
fclose(fileID);

