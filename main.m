clear;close all; clc;

data = readtable('xyz_psi_theta');
t = data.time;

%描画
figure(); hold on; box('off')
axis equal;
xlabel('x');ylabel('y');zlabel('z');
grid on;view (3)

interval = 4; %飛行機の表示間隔 
scale = 1; %飛行機のサイズ

for i=1:interval:length(t)
 	aircraft_figure(data.x(i),data.y(i),data.z(i),data.psi(i),data.theta(i)+pi,0,scale);
%      stem3(data.x(1:interval:i),data.y(1:interval:i),data.z(1:interval:i),'MarkerSize',1);
  	plot3(data.x(1:interval:i),data.y(1:interval:i),data.z(1:interval:i));
    refresh;
end

%x軸回転
function R_x = Rotation_X(Psi)
	R_x = [ cos(Psi), sin(Psi), 0;
               -sin(Psi), cos(Psi), 0;
                       0,        0, 1 ];
end

%y軸回転
function R_y = Rotation_Y(Theta)
	R_y = [ cos(Theta), 0, -sin(Theta);
                         0, 1,           0;
                sin(Theta), 0,   cos(Theta) ];
end

%z軸回転
function R_z = Rotation_Z(Phi)
	R_z = [1,         0,        0;
               0,  cos(Phi), sin(Phi);
               0, -sin(Phi), cos(Phi) ];
end

function [] = aircraft_figure(x,y,z,Psi,Theta,Phi,scale)
	%飛行機の3Dグラフィックを描画する関数
	%引数は重心座標，ロールピッチヨー角，飛行機のサイズ
	%ポリゴンの頂点を定義して，lineオブジェクトで繋ぐ

	%xz平面に対する鏡像ベクトルを作るための写像行列
	mirror = [1,0,0;0,-1,0;0,0,1];

	%主翼オブジェクト
	p1 = [0+3,0 ,-0];
	p2 = [-4+3,1 ,-0];
	p3 = [-4+3,-1,-0];
	p4 = [-3+3,0,-0.2];
	w1 = vertcat(p1,p2,p3,p1);%主翼
	w2 = vertcat(p1,p2,p4,p1);%右舷
	w3 = (mirror * w2')';%左舷

	%尾翼オブジェクト
	p1 = [-3.0+3,0.3,-0];
	p2 = [-3.8+3,0.5,-0.6];
	p3 = [-4.2+3,0.5,-0.6];
	p4 = [-4.0+3,0.3,-0];
	tail_r = vertcat(p1,p2,p3,p4,p1);%右尾翼
	tail_l = (mirror * tail_r')';%左尾翼

	%オブジェクトのスケールを変更する
	w1 = w1 * scale;
	w2 = w2 * scale;
	w3 = w3 * scale;
	tail_r = tail_r * scale;
	tail_l = tail_l * scale;

	%オブジェクトを回転させる
	DCM = Rotation_X(-Psi) * Rotation_Y(-Theta) * Rotation_Z(-Phi);
	w1 = (DCM * w1')';
	w2 = (DCM * w2')';
	w3 = (DCM * w3')';
	tail_r = (DCM * tail_r')';
	tail_l = (DCM * tail_l')';

	%オブジェクトを平行移動させる
	w1     = translational_shift(w1,x,y,z);
	w2     = translational_shift(w2,x,y,z);
	w3     = translational_shift(w3,x,y,z);
	tail_r = translational_shift(tail_r,x,y,z);
	tail_l = translational_shift(tail_l,x,y,z);

	%描画する
	line(w1(:,1),w1(:,2),w1(:,3));
	line(w2(:,1),w2(:,2),w2(:,3));
	line(w3(:,1),w3(:,2),w3(:,3));
	line(tail_r(:,1),tail_r(:,2),tail_r(:,3));
	line(tail_l(:,1),tail_l(:,2),tail_l(:,3));

end

function result = translational_shift(object,x,y,z)
	%頂点群objectを[x,y,z]だけ平行移動させる
	shift_x = x*ones(size(object,1),1);
	shift_y = y*ones(size(object,1),1);
	shift_z = z*ones(size(object,1),1);
	shift   = horzcat(shift_x,shift_y,shift_z);

	result = object + shift;
end
