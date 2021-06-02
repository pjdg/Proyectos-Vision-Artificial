%Trabajo 2. Eliminaci�n de distorsi�n en imagen. (Por Pedro Jos� D�az Garc�a)
clear all; close all;

%Al ejecutar el programa, se le pide al usuario que decida qu� tipo de
%imagen y qu� tipo de interpolaci�n utilizar. En caso de que el usuario
%seleccione un valor no v�lido, se mostrar� un mensaje de error y se
%volver� a ejecutar el programa.
tipo_imagen=input('Seleccione la imagen a usar: 1=barrel  2=pincushion \n');
tipo_interpolacion=input('Seleccione el tipo de interpolaci�n que utilizar�: 0=vecino m�s pr�ximo  1=bilineal \n');

%%DEFINICI�N DE DATOS Y PAR�METROS

%Se carga la imagen seleccionada por el usuario, junto a su correspondiente
%factor de distorsi�n. Se muestra el mensaje de error en caso de que sea
%necesario.
if (tipo_imagen==1)
    imagen_distorsion=imread('chessBoardDistorted1.jpg');
    kr1=-0.4320; %Coeficiente de distorsi�n radial
elseif (tipo_imagen==2)
    imagen_distorsion=imread('chessBoardDistorted2.jpg');
    kr1=0.4320; %Coeficiente de distorsi�n radial
else
    disp('ERROR: No se ha seleccionado una imagen disponible'); %Mensaje de error.
    run('Codigo_trabajo_practico_2');
end
    
f=0.0042; %Distancia focal (m)
N=1000; M=1000; %Resoluci�n de la imagen (N:ancho, M:alto) (pix)
w=0.00496; h=0.00352; %Tama�o del sensor (w:ancho, h:alto) (m)
u0=N/2+1; v0=M/2-2; %Punto principal de la imagen (pix)
fx=f*N/w; fy=f*M/h; %Longitudes focales efectivas


%%CORRECCI�N DE LA DISTORSI�N
imagen_corregida=[];
dimagen_distorsion=double(imagen_distorsion); %Para operar, pasar la imagen a tratar a double.

%Se recorre cada p�xel de la imagen corregida...
for u=1:N
    for v=1:M
        %C�lculo del p�xel distorsionado correspondiente al p�xel de la
        %imagen corregida.
        xn=(u-u0)/fx;
        yn=(v-v0)/fy;
        
        xnd=xn*(1+kr1*(xn^2+yn^2));
        ynd=yn*(1+kr1*(xn^2+yn^2));
                
        ud=xnd*fx+u0;
        vd=ynd*fy+v0;
               
        %Saturaci�n en caso de que el c�lculo del p�xel distorsionado resulte fuera de los l�mites de la imagen.
        %En este caso, se asigna un valor de intensidad arbitrario.
        if(vd<1 || vd>M || ud<1 || ud>N)
            imagen_corregida(v,u)=127;
        else
            %Aplicaci�n del tipo de interpolaci�n elegida por el usuario. En caso de que el usuario
            %seleccione un valor no v�lido, se mostrar� un mensaje de error y se volver� a ejecutar el programa.
            
            %%INTERPOLACI�N BILINEAL
            if(tipo_interpolacion==1) 
                %C�lculo de las coordenadas enteras de los p�xeles m�s
                %pr�ximos al p�xel distorsionado calculado.
                vd1=floor(vd);
                vd2=ceil(vd);
                ud1=floor(ud);
                ud2=ceil(ud);
            
                %Se determina la intensidad del p�xel de la imagen
                %corregida como una ponderaci�n por proximidad de las
                %intensidades de los cuatro p�xeles m�s cercanos al p�xel distorsionado calculado. 
                imagen_corregida(v,u)=(vd2-vd)*(ud2-ud)*dimagen_distorsion(vd1,ud1)+...
                                (vd2-vd)*(ud-ud1)*dimagen_distorsion(vd1,ud2)+...
                                (vd-vd1)*(ud2-ud)*dimagen_distorsion(vd2,ud1)+...
                                (vd-vd1)*(ud-ud1)*dimagen_distorsion(vd2,ud2);
                            
                           
            %%INTERPOLACI�N POR EL VECINO M�S PR�XIMO                
            elseif (tipo_interpolacion==0) 
                 %C�lculo de las coordenadas enteras del p�xel m�s
                 %pr�ximo al p�xel distorsionado calculado.
                 vd=round(vd);
                 ud=round(ud);           
                         
                 %La intensidad de este �ltimo p�xel calculado ser� la
                 %intensidad del p�xel corrspondiente en la imagen
                 %corregida.
                 imagen_corregida(v,u)=dimagen_distorsion(vd,ud);
             
            else
                disp('ERROR: No se ha seleccionado un tipo de interpolaci�n correcto'); %Mensaje de error.
                run('Codigo_trabajo_practico_2');
            end
        end
    end
end

imagen_corregida=uint8(imagen_corregida); %Para mostrar la imagen, pasarla a uint8.

%Representaci�n conjunta de la imagen distorsionada y su correcci�n.
figure(1);
subplot(1,2,1);imshow(imagen_distorsion);title('Imagen distorsionada');
subplot(1,2,2);imshow(imagen_corregida);title('Imagen corregida');

