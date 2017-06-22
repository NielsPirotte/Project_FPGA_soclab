A = imread('background.jpg'); %256 * 256
[n, m, c] = size(A);

%threshold = 100;

fileID = fopen('background.mif','wt');

%header
fprintf(fileID, '\n-- Clearbox generated Memory Initialization File (.mif)\n\n');
fprintf(fileID, 'WIDTH=12;\n');
fprintf(fileID, 'DEPTH=65536;\n\n');
fprintf(fileID, 'ADDRESS_RADIX=HEX;DATA_RADIX = HEX;\n\n');
fprintf(fileID, 'CONTENT BEGIN\n');

%body
R = zeros(n, m);

number = 0;
for i = 1:n
    for j = 1:m
        formatSpec1 = '\t%3x  :\t';
        fprintf(fileID, formatSpec1, number);
        
        pixelvalr = A(i, j, 1);
        pixelvalg = A(i, j, 2);
        pixelvalb = A(i, j, 3);

        r = false;
        g = false;
        b = false;
        if (pixelvalr > threshold)  
            r = true;
        end
        if (pixelvalg > threshold) 
            g = true;
        end
        if (pixelvalb > threshold)  
            b = true;
        end

        if ((r && b && g)||(~r && ~b && ~g)) 
            value = 0;
        else
            if (r)
               value = 1;
            elseif (g) 
               value = 2;
            else
               value = 3;
            end
        end
        
        formatSpec2 = '%3x;\n';
        fprintf(fileID, formatSpec2, value);
        R(i,j) = value;
        number = number +1;
    end
end

%footer
fprintf(fileID,'END\n');
fclose(fileID);

