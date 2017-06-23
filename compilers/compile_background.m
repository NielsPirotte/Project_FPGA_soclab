A = imread('background_test_bit_brown.jpg'); %256 * 256
[n, m, c] = size(A);

%threshold = 100;

fileID = fopen('background_test.mif','wt');

%header
fprintf(fileID, '\n-- Clearbox generated Memory Initialization File (.mif)\n\n');
fprintf(fileID, 'WIDTH=12;\n');
fprintf(fileID, 'DEPTH=65536;\n\n');
fprintf(fileID, 'ADDRESS_RADIX=HEX;\nDATA_RADIX = HEX;\n\n');
fprintf(fileID, 'CONTENT BEGIN\n');

number = 0;
for i = 1:n
    for j = 1:m
        formatSpec1 = '\t%3X  :\t';
        fprintf(fileID, formatSpec1, number);
        
        pixelvalr = A(i, j, 1);
        pixelvalg = A(i, j, 2);
        pixelvalb = A(i, j, 3);
       
        pixelvalrh = dec2hex(pixelvalr);
        pixelvalrh = pixelvalrh(1);
        pixelvalgh = dec2hex(pixelvalg);
        pixelvalgh = pixelvalgh(1);
        pixelvalbh = dec2hex(pixelvalb);
        pixelvalbh = pixelvalbh(1);
        
        if pixelvalrh == 'F'
           pixelvalgh = 'F';
           pixelvalbh = 'F';
        end
        
        formatSpec2 = '%s%s%s ;\n';
        fprintf(fileID, formatSpec2, pixelvalrh, pixelvalgh, pixelvalbh);
        number = number + 1;
    end
end

%footer
fprintf(fileID,'END\n');
fclose(fileID);

