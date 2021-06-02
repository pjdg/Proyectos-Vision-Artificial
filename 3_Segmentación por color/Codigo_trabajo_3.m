%Trabajo 3. Segmentación por color. (Por Pedro José Díaz García)
clear all;close all;clc;

%Obtención de la imagen de trabajo.
imagen_original=imread('imagenDePartida.png');

%Obtención de cada uno de los canales RGB de la imagen.
canal_rojo  = imagen_original(:,:,1);
canal_verde = imagen_original(:,:,2);
canal_azul  = imagen_original(:,:,3);

%Matriz de valores umbrales obtenidos con la herramienta colorThresholder. 
%Orden: {rojo,amarillo, naranja, verde, azul,negro}.
          %Rmin Rmax Gmin Gmax Bmin Bmax
umbrales=[  90   255  12   64   13   181;
           177   255 156  255    0    64;
    	   209   255   0  146    0   255;
             0   150 155  255   23   144;
		     0    97   0  145  108   255;
    	    21    91   0   88    0    86];

%Proceso de segmentación para cada uno de los colores.        
for c=1:6  
% 1. Obtención y aplicación de la plantilla para filtrar uno de los colores.    
filtro_rojo=(umbrales(c,1) <= canal_rojo & canal_rojo <= umbrales(c,2));
filtro_verde=(umbrales(c,3) <= canal_verde & canal_verde <= umbrales(c,4));
filtro_azul=(umbrales(c,5) <= canal_azul & canal_azul <= umbrales(c,6));

plantilla=filtro_rojo & filtro_verde & filtro_azul;

plantilla3=[];
plantilla3(:,:,1)=plantilla;
plantilla3(:,:,2)=plantilla;
plantilla3(:,:,3)=plantilla;

lacasitos=imagen_original.*uint8(plantilla3);
% figure(c+1);imshow(lacasitos); %imagen con solo lacasitos de un color

 
% 2. Acondicionamiento de la imagen: se reliza una apertura para eliminar los
%píxeles dispersos, y un cierre para rellenar los elementos que quedan.
mask=strel('disk',2);
lacasitos=imopen(lacasitos,mask);
% lacasitos=imclose(lacasitos,mask);
% figure(c+2);imshow(lacasitos); %imagen una vez tratada


% 3. Etiquetado de los elementos de la imagen.
[m_etiq,num_etiq]=bwlabel(255*uint8(imopen(plantilla,mask)));
% figure(c+3); %representa individualmente cada uno de los elementos 
% for i=1:num_etiq
%    lacasito_i = imagen_original .* uint8(m_etiq==i);
%    imshow(lacasito_i);
%    pause;
% end

% 4. Obtención de las propiedades de los objetos etiquetados.
propiedades=regionprops(m_etiq,'Centroid','BoundingBox');

%muestra sobre la imagen original el bounding box de cada elemento y su
%centroide.
figure(c+4);imshow(imagen_original);hold on; 
for i=1:num_etiq
    box=propiedades(i).BoundingBox;
    centro=propiedades(i).Centroid;
    centro=round(centro);
    hold on;rectangle('Position',box,'EdgeColor','g','LineWidth',2);
    hold on;plot(centro(1),centro(2),'b.','MarkerSize',20);
end
    pause;
end

