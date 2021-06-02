%Trabajo 1. Formaci�n de la imagen. (Por Pedro Jos� D�az Garc�a)
clear all;close all;

%BLOQUE 1: DEFINICI�N DEL OBJETO, DE LOS PAR�METROS DE LA C�MARA Y DE LA
%CONFIGURACI�N ESPACIAL DE LA C�MARA RESPECTO DEL OBJETO.

    %Al ejecutar el programa, se le pide al usuario que decida si quiere
    %tner en cuenta el efecto de la distorsi�n o no.
     distor=input('�Tener en cuenta la distorsi�n? Yes:1 No:0\n'); 
     
    %DEFINICI�N DEL OBJETO
        %Datos relativos al objeto.
        num_px=31; %N�mero de puntos en el eje horizontal
        num_py=15; %N�mero de puntos en el eje vertical
        dx=0.01;   %Separaci�n(en m) entre puntos en el eje horizontal
        dy=0.01;   %Separaci�n(en m) entre puntos en el eje vertical
        wx=0;wy=0;wz=0; %Coordenadas del origen del sistema de referencia del objeto {W}

        %Matriz que contiene las coordenadas de todos los puntos del objeto
        % [ x1    x2    x3   . . . . .  xn]
        % [ y1    y2    y3   . . . . .  yn]
        % [ z1    z2    z3   . . . . .  zn]
        P=[];
        for i=1:num_px
            for j=1:num_py
                P=[P [wx+(i-1)*dx;wy+(j-1)*dy;wz]];
            end
        end

    %PAR�METROS DE LA C�MARA
        %Datos relativos a la c�mara
        f=0.0042; %Distancia focal (m)
        N=4128; M=3096; %Resoluci�n de la imagen (N:ancho, M:alto) (pix)
        w=0.00496; h=0.00352; %Tama�o del sensor (w:ancho, h:alto) (m)
        u0=round(N/2)+1; v0=round(M/2)-2; %Punto principal de la imagen (pix)
        s=0; %skew
        kr1=0.144; kr2=-0.307; %Coeficientes de distorsi�n radial
        kt1=-0.0032; kt2=0.0017; %Coeficientes de distorsi�n tangencial

        %C�lculo de matriz de par�metros intr�nsecos
        rox=w/N; %Dimensi�n efectiva del p�xel en el eje horizontal
        roy=h/M; %Dimensi�n efectiva del p�xel en el eje vertical
        A=[f/rox s*f/rox u0;0 f/roy v0;0 0 1]; %Matriz de par�metros intr�nsecos

    %CONFIGURACI�N ESPACIAL DE LA C�MARA
    %Declaraci�n de una serie de configuraciones predeterminadas, pensadas
    %para el posterior an�lisis de resultados.
    
        %1_Distancia media y enfoque recto hacia el objeto (inicial).
        wtc=[round((num_px-1)/2)*dx,round((num_py-1)/2)*dy,0.4]'; %Vector traslaci�n de {C} respecto {W}
        Rx=[1 0 0;0 cos(pi) -sin(pi);0 sin(pi) cos(pi)];
        wRc=Rx; %Matriz de rotaci�n de {C} respecto {W}
        wTc=[wRc wtc;0 0 0 1]; %Matriz de par�metros extr�nsecos (matriz de transformaci�n homog�nea)
        WTC(:,:,1)=wTc; %Almacenamiento de las transformaciones homog�neas {W}-{C}
        cTw=inv(wTc);
        CTW(:,:,1)=cTw; %Almacenamiento de las transformaciones homog�neas {C}-{W}
        
        %2_Acercamiento, enfoque recto.
        wtc=[round((num_px-1)/2)*dx,round((num_py-1)/2)*dy,0.15]'; 
        Rx=[1 0 0;0 cos(pi) -sin(pi);0 sin(pi) cos(pi)];
        wRc=Rx;
        wTc=[wRc wtc;0 0 0 1];
        WTC(:,:,2)=wTc;
        cTw=inv(wTc);
        CTW(:,:,2)=cTw;
        
        %3_Alejamiento, enfoque recto.
        wtc=[round((num_px-1)/2)*dx,round((num_py-1)/2)*dy,0.6]'; 
        Rx=[1 0 0;0 cos(pi) -sin(pi);0 sin(pi) cos(pi)];
        wRc=Rx;
        wTc=[wRc wtc;0 0 0 1];
        WTC(:,:,3)=wTc;
        cTw=inv(wTc);
        CTW(:,:,3)=cTw;
        
        %4_Desplazamiento lateral, enfoque recto.
        wtc=[round((num_px-1)/2)*dx+0.1,round((num_py-1)/2)*dy+0.1,0.4]'; 
        Rx=[1 0 0;0 cos(pi) -sin(pi);0 sin(pi) cos(pi)];
        wRc=Rx;
        wTc=[wRc wtc;0 0 0 1];
        WTC(:,:,4)=wTc;
        cTw=inv(wTc);
        CTW(:,:,4)=cTw;
        
        %5_Desplazamiento lateral hacia el otro lado, enfoque recto.
        wtc=[round((num_px-1)/2)*dx-0.1,round((num_py-1)/2)*dy-0.1,0.4]';
        Rx=[1 0 0;0 cos(pi) -sin(pi);0 sin(pi) cos(pi)];
        wRc=Rx;
        wTc=[wRc wtc;0 0 0 1];
        WTC(:,:,5)=wTc;
        cTw=inv(wTc);
        CTW(:,:,5)=cTw;
        
        %6_Desplazamiento lejano.
        wtc=[round((num_px-1)/2)*dx+1,round((num_py-1)/2)*dy,0.4]'; 
        Rx=[1 0 0;0 cos(pi) -sin(pi);0 sin(pi) cos(pi)];
        wRc=Rx;
        wTc=[wRc wtc;0 0 0 1];
        WTC(:,:,6)=wTc;
        cTw=inv(wTc);
        CTW(:,:,6)=cTw;
        
        %7_Posici�n incial con giro alrededor del eje de la c�mara.
        wtc=[round((num_px-1)/2)*dx,round((num_py-1)/2)*dy,0.4]';
        Rx=[1 0 0;0 cos(pi) -sin(pi);0 sin(pi) cos(pi)];
        Rz=[cos(pi/2) -sin(pi/2) 0; sin(pi/2) cos(pi/2) 0;0 0 1];
        wRc=Rx*Rz;
        wTc=[wRc wtc;0 0 0 1];
        WTC(:,:,7)=wTc;
        cTw=inv(wTc);
        CTW(:,:,7)=cTw;
        
        %8_Posici�n inicial con inclinaci�n.
        wtc=[round((num_px-1)/2)*dx,round((num_py-1)/2)*dy,0.4]'; 
        Rx=[1 0 0;0 cos(pi) -sin(pi);0 sin(pi) cos(pi)];
        Ry=[cos(-pi/6) 0 sin(-pi/6);0 1 0;-sin(-pi/6) 0 cos(-pi/6)];
        wRc=Rx*Ry;
        wTc=[wRc wtc;0 0 0 1];
        WTC(:,:,8)=wTc;
        cTw=inv(wTc);
        CTW(:,:,8)=cTw;
        
        %9_Desplazamiento y cambio arbitrario de orientaci�n combinados.
        wtc=[round((num_px-1)/2)*dx+0.1,round((num_py-1)/2)*dy+0.1,0.4]'; 
        Rx=[1 0 0;0 cos(pi) -sin(pi);0 sin(pi) cos(pi)];
        Ry=[cos(-pi/5) 0 sin(-pi/5);0 1 0;-sin(-pi/5) 0 cos(-pi/5)];
        Rz=[cos(2*pi/5) -sin(2*pi/5) 0;sin(2*pi/5) cos(2*pi/5) 0;0 0 1];
        wRc=Rx*Ry*Rz;
        wTc=[wRc wtc;0 0 0 1];
        WTC(:,:,9)=wTc;
        cTw=inv(wTc);
        CTW(:,:,9)=cTw;
        
        
%BLOQUE 2: C�LCULO DE LA PROYECCI�N DE LOS PUNTOS EN EL PLANO DE LA IMAGEN
    
    %Se hacen homog�neas las coordenadas de los puntos del objeto
    P_=[P;ones(1,size(P,2))];
    
    %Bucle que recorre las configuraciones definidas anteriormente; incluye
    %c�lculo de la proyecci�n correspondiente y su representaci�n.
    for j=1:1
        %Se espera a que el usuario pida ver la siguiente posici�n
        fprintf('Pulsar intro para ver el paso %d \n',j)
        pause;
        
        %C�lculo sin tener en cuenta la distorsi�n
        p_=A*CTW(1:3,:,j)*P_; 
        for i=1:size(p_,2)
           p(:,i)=p_(1:2,i)/p_(3,i);
        end

        %C�lculo teniendo en cuenta la distorsi�n 
        if distor==1
            
            %Paso de las coordenadas calculadas anteriormente (en p�xeles)
            %a coordenadas en m, y normalizar.
            pn=[1/f*rox 0;0 1/f*roy]*(p-[u0;v0]); 
            
            %C�lculo de posiciones distorsionadas
            for i=1:size(pn,2)
                pd(:,i)=pn(:,i)*(1+kr1*norm(pn(:,i))^2+kr2*norm(pn(:,i))^4)+...
                    +[2*kt1*pn(1,i)*pn(2,i)+kt2*(norm(pn(:,i))^2+2*pn(1,i)^2);
                    2*kt2*pn(1,i)*pn(2,i)+kt1*(norm(pn(:,i))^2+2*pn(2,i)^2)];
            end
            
            %Se deshace el paso realizado previamente a la aplicaci�n de la
            %distorsi�n
            p=[f/rox 0;0 f/roy]*pd+[u0;v0];
        end    

%BLOQUE 3: REPRESENTACI�N GR�FICA

    %Representaci�n de la matriz de puntos en el esapcio tridimensional
    figure(j);subplot(1,2,1);
    plot3(P(1,:),P(2,:),P(3,:),'k.');
    grid;
    xlabel('Eje X (m)');ylabel('Eje Y (m)');zlabel('Eje Z (m)');
    title('Espacio real');

    %Representaci�n de los ejes {W} en el plano tridimensional 
    %(rojo:x, verde:y, azul:z)
    ejewx=[wx wx+0.1;wy wy;wz wz];
    ejewy=[wx wx;wy wy+0.1;wz wz];
    ejewz=[wx wx;wy wy;wz wz+0.1];
    line(ejewx(1,:),ejewx(2,:),ejewx(3,:),'color','r','LineWidth',2);
    line(ejewy(1,:),ejewy(2,:),ejewy(3,:),'color','g','LineWidth',2);
    line(ejewz(1,:),ejewz(2,:),ejewz(3,:),'color','b','LineWidth',2);

    %Representaci�n de los ejes {C} en el plano tridimensional 
    %(rojo:x, verde:y, azul:z).
    ejecx=WTC(:,:,j)*[ejewx;1 1];
    ejecy=WTC(:,:,j)*[ejewy;1 1];
    ejecz=WTC(:,:,j)*[ejewz;1 1];
    line(ejecx(1,:),ejecx(2,:),ejecx(3,:),'color','r','LineWidth',2);
    line(ejecy(1,:),ejecy(2,:),ejecy(3,:),'color','g','LineWidth',2);
    line(ejecz(1,:),ejecz(2,:),ejecz(3,:),'color','b','LineWidth',2);

    %Representaci�n del plano de la imagen
%         subplot(1,2,2);
        %Marco del plano imagen
        axis([-100 4228 -100 3196]);
        rectangle('Position',[0 0 N M]);
        hold on;
        %Puntos proyectados
        plot(p(1,:),p(2,:),'.');
        %Proyecci�n de los ejes Wx y Wy
        line([p(1,1) p(1,(num_px-1)*num_py+1)],[p(2,1) p(2,(num_px-1)*num_py+1)],'color','r','LineWidth',1);
        line([p(1,1) p(1,num_py)],[p(2,1) p(2,num_py)],'color','g','LineWidth',1);
        set(gca,'YDir','reverse');
        xlabel('Eje horizontal (pix)');ylabel('Eje vertical (pix)');
        title('Plano imagen');
        grid;
end
