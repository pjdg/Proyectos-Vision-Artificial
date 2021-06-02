function Realidad_virtual(imagen,distorsion,fc,cc,kc,alpha_c)

f=imagen;

%DETECCIÓN DE PUNTOS DE REFERENCIA PARA OBTENER PARÁMETROS EXTRÍNSECOS

%Binarización
fgray=rgb2gray(f);
% figure(1); imshow(fgray);
fbin=fgray<60;
% figure(2); imshow(fbin);

%Eliminación de bordes mediante una plantilla de ceros y unos.
[M,N]=size(fbin);
plantilla_bordes=zeros(M,N);
w=70; %Anchura del borde a eliminar
for i=w:M-w
    for j=w:N-w
        plantilla_bordes(i,j)=1;
    end
end

fbin=fbin & plantilla_bordes;
% figure(3); imshow(fbin);


%Aplicación de apertura para eliminar líneas del objeto de referencia, ya que solo interesan los círculos.
mask=strel('disk',4);
flimpia=imopen(fbin,mask);
% figure(4); imshow(flimpia);

%Determinación de regiones y datos característicos. Se usarán los centros
%para determinar la posición de los puntos de referencia, y el BBox para
%determinar cual de ellos es el origen.
[etiq,netiq]=bwlabel(flimpia);
datos=regionprops(etiq,'Centroid','BoundingBox');
centros=[];
LmaxBBox=[];
% figure(5);
imshow(f);
for i=1:netiq
    centros=[centros datos(i).Centroid'];
    LmaxBBox(i)=max(datos(i).BoundingBox(3:4)); %solo interesan las dimensiones del BBox
    hold on;plot(datos(i).Centroid(1),datos(i).Centroid(2),'*');
end

%Determinación de ejes de referencia
    %El origen corresponderá a aquella región con una mayor dimensión del
    %BBox. 
    [~,etiq_origen]=max(LmaxBBox);
    origen=centros(:,etiq_origen);

    %El eje Y lo determinará el punto más cercano al origen. Por otra
    %parte, el eje X lo determinará aquel punto que haga que el producto
    %escalar del vector que forma con el origen, por el vector del ejeY sea
    %mínimo.
    distancias=[];
    vectores=[];
    for i=1:size(centros,2)
        vectores(:,i)=centros(:,i)-origen;
        distancias(i)=norm(vectores(:,i));
    end
    [distancias, indices]=sort(distancias);

    %Eje X 
    [~,ind]=min([abs(vectores(:,indices(2))'*vectores(:,indices(3))) abs(vectores(:,indices(2))'*vectores(:,indices(4)))]);
    ejeX=centros(:,indices(ind+2));
    hold on; line([origen(1) ejeX(1)],[origen(2) ejeX(2)],'Color','r');

    %Eje Y
    ejeY=centros(:,indices(2));
    hold on; line([origen(1) ejeY(1)],[origen(2) ejeY(2)],'Color','b');


%Construcción de matrices MP y mp.

    %MP contiene, por columnas, las coordenadas de los puntos de
    %característicos del objeto de referencia expresados en los ejes del objeto
    %de referencia. Se han intercambiado las coordenadas x e y porque los
    %ejes calculados están invertidos respecto a los ejes considerados por
    %la función compute_extrinsic()
    MP=[0 0 0;0 220 0;115 0 0;115 220 0]';
    
    %mp contiene, por columnas, las coordenadas en píxeles de de los puntos
    %característicos del objeto de referencia. La ordenación de estos
    %dentro de la matriz debe concordar con la ordenación en MP.
    mp=[origen centros(:,indices(ind+2)) centros(:,indices(2)) centros(:,indices(length(centros)-(ind-1)))];

%Uso de compute_extrinsic() para obtener los parámetros extrínsecos.
[~, cto, cRo, ~] = compute_extrinsic (mp, MP, fc, cc, kc, alpha_c);


%REPRESENTACIÓN DE LOS OBJETOS VIRTUALES
%Puntos para graficar monigote
Pmonigote=[ 57.5   57.5   57.5   57.5   57.5   57.5   57.5  57.5;
             135    185    160    160    160    160    135   185;
               0      0     30     60     70     80     50    50];

%Puntos para graficar casa
Pcasa=[ 30 30  0; 90 30 0 ; 90 90 0; 30 90 0;
        30 30 50; 90 30 50; 90 90 50;30 90 50;
        60 60 75]';

%Construcción de la matriz de parámetros intrísecos con los valores
%obtenidos en la calibración.
MIntrins=[fc(1) 0 cc(1);0 fc(2) cc(2);0 0 1];

%Cálculo de las coordenadas en píxeles de los puntos de los objetos
%virtuales
if (distorsion==0)
    %Sin distorsión
    p_monigote=MIntrins*[cRo cto]*[Pmonigote;ones(1,size(Pmonigote,2))];
    p_casa=MIntrins*[cRo cto]*[Pcasa;ones(1,size(Pcasa,2))];

    pmonigote=p_monigote(1:2,:)./p_monigote(3,:);
    pcasa=p_casa(1:2,:)./p_casa(3,:);
else

    %Con ditorsión
    p_monigote=[cRo cto]*[Pmonigote;ones(1,size(Pmonigote,2))];
    p_casa=[cRo cto]*[Pcasa;ones(1,size(Pcasa,2))];

    Pnmonigote=p_monigote(1:2,:)./p_monigote(3,:);
    Pncasa=p_casa(1:2,:)./p_casa(3,:);

    for i=1:size(Pnmonigote,2)
        r=norm(Pnmonigote(:,i));
        Pndmonigote(:,i)=Pnmonigote(:,i)*(1+kc(1)*r^2+kc(2)*r^4)+...
            +[2*kc(3)*Pnmonigote(1,i)*Pnmonigote(2,i)+kc(4)*(r^2+2*Pnmonigote(1,i)^2);
            2*kc(4)*Pnmonigote(1,i)*Pnmonigote(2,i)+kc(3)*(r^2+2*Pnmonigote(2,i)^2)];
    end
    for i=1:size(Pncasa,2)
        r=norm(Pncasa(:,i));
        Pndcasa(:,i)=Pncasa(:,i)*(1+kc(1)*r^2+kc(2)*r^4)+...
            +[2*kc(3)*Pncasa(1,i)*Pncasa(2,i)+kc(4)*(r^2+2*Pncasa(1,i)^2);
            2*kc(4)*Pncasa(1,i)*Pncasa(2,i)+kc(3)*(r^2+2*Pncasa(2,i)^2)];
    end

    pmonigote=[fc(1) 0;0 fc(2)]*Pndmonigote+[cc(1);cc(2)];
    pcasa=[fc(1) 0;0 fc(2)]*Pndcasa+[cc(1);cc(2)];

end

%Dibujo de los puntos resultantes sobre la imagen
hold on;
linea(pmonigote(:,1),pmonigote(:,3));
linea(pmonigote(:,2),pmonigote(:,3));
linea(pmonigote(:,3),pmonigote(:,4));
linea(pmonigote(:,4),pmonigote(:,7));
linea(pmonigote(:,4),pmonigote(:,8));
linea(pmonigote(:,4),pmonigote(:,5));
viscircles(pmonigote(:,6)',norm(pmonigote(:,5)-pmonigote(:,6)));

linea(pcasa(:,1),pcasa(:,2));
linea(pcasa(:,2),pcasa(:,3));
linea(pcasa(:,3),pcasa(:,4));
linea(pcasa(:,4),pcasa(:,1));
linea(pcasa(:,5),pcasa(:,6));
linea(pcasa(:,6),pcasa(:,7));
linea(pcasa(:,7),pcasa(:,8));
linea(pcasa(:,8),pcasa(:,5));
linea(pcasa(:,1),pcasa(:,5));
linea(pcasa(:,2),pcasa(:,6));
linea(pcasa(:,3),pcasa(:,7));
linea(pcasa(:,4),pcasa(:,8));
linea(pcasa(:,5),pcasa(:,9));
linea(pcasa(:,6),pcasa(:,9));
linea(pcasa(:,7),pcasa(:,9));
linea(pcasa(:,8),pcasa(:,9));


function linea(p1, p2)
    line([p1(1) p2(1)],[p1(2) p2(2)]);
end
end
