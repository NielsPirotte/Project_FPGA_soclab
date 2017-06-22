A = imread('walking_ken_p.png'); %200 * 105
[n, m, c] = size(A);

fileID = fopen('walking.mif','wt');

%header
fprintf(fileID, '\n-- Clearbox generated Memory Initialization File (.mif)\n\n');
fprintf(fileID, 'WIDTH=4;\n');
fprintf(fileID, 'DEPTH=32768;\n\n');
fprintf(fileID, 'ADDRESS_RADIX = HEX;\nDATA_RADIX = HEX;\n\n');
fprintf(fileID, 'CONTENT BEGIN\n');

number = 0;
for i = 1:n
    for j = 1:m
        formatSpec1 = '\t%3X  :\t';
        fprintf(fileID, formatSpec1, number);
        
        pixelvalr = A(i, j, 1);
        pixelvalg = A(i, j, 2);
        pixelvalb = A(i, j, 3);
        
        switch pixelvalr
            case 25 %19
                v = 1;
            case 76 %4c
                v = 2; 
            case 178 %b2
                v = 3;
            case 127 %7f
                if pixelvalg == 0
                    v = 5;
                else
                    v = 11;
                end
            case 204 %cc
                v = 7;
            case 0
                switch pixelvalb
                    case 127 %7f
                        if pixelvalg == 0
                            v = 8;
                        else
                            v = 9;
                        end                        
                    case 255 %ff
                        v = 10;
                    case 0 
                        if pixelvalg == 127 %7f
                            v = 4;
                        else 
                            v = 12;
                        end
                end
            otherwise
                if pixelvalg == 0
                    v = 6;
                else
                    v = 0;
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

