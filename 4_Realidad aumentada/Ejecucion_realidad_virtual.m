clear all; clc; close all;
distorsion=input('Introduzca si quiere tratar sin distorsión(0) o con distorsión (1):');
load('Calib_Results.mat');

%Para ver secuencia
imagen=imread('rectangulo6.jpg'); figure(1);
Realidad_virtual(imagen,distorsion,fc,cc,kc,alpha_c);
imagen=imread('rectangulo7.jpg'); figure(2);
Realidad_virtual(imagen,distorsion,fc,cc,kc,alpha_c);
imagen=imread('rectangulo9.jpg'); figure(3);
Realidad_virtual(imagen,distorsion,fc,cc,kc,alpha_c);
imagen=imread('rectangulo8.jpg'); figure(4);
Realidad_virtual(imagen,distorsion,fc,cc,kc,alpha_c);

%Descomentar para ver resto de imágenes
% imagen=imread('rectangulo5.jpg'); figure(5);
% Realidad_virtual(imagen,distorsion,fc,cc,kc,alpha_c);
% imagen=imread('rectangulo6.jpg'); figure(6);
% Realidad_virtual(imagen,distorsion,fc,cc,kc,alpha_c);
% imagen=imread('rectangulo7.jpg'); figure(7);
% Realidad_virtual(imagen,distorsion,fc,cc,kc,alpha_c);
% imagen=imread('rectangulo8.jpg'); figure(8);
% Realidad_virtual(imagen,distorsion,fc,cc,kc,alpha_c);
% imagen=imread('rectangulo9.jpg'); figure(9);
% Realidad_virtual(imagen,distorsion,fc,cc,kc,alpha_c);



