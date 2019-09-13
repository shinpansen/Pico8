pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
pi = 3.14159

function tan(a) 
	return sin(a)/cos(a) 
end

function create_vect3d()
 local tri = {x=0,y=0,z=0}
 return tri
end

function create_triangle()
 local tri = {}
 for i=1,3 do 
  add(tri,create_vect3d())
 end
 return tri
end

function create_matrix(r,c)
 local m = {}
 for i=1,r do
  add(m,{})
 	for j=1,c do
 	 m[i][j] = 0
 	end
	end
	return m
end

function multiply_mat(i,o,m)
 o.x = i.x*m[1][1]+i.y*m[2][1]+i.z*m[3][1]+m[4][1]
 o.y = i.x*m[1][2]+i.y*m[2][2]+i.z*m[3][2]+m[4][2]
 o.z = i.x*m[1][3]+i.y*m[2][3]+i.z*m[3][3]+m[4][3]
 local w = i.x*m[1][4]+i.y*m[2][4]+i.z*m[3][4]+m[4][4]
 if(w != 0) then
 	o.x /= w
 	o.y /= w
 	o.z /= w
 end
end

function draw_triangle(ax,ay,bx,by,cx,cy)
 col = flr(rnd(16))
 line(ax,ay,bx,by,col)
 line(bx,by,cx,cy,col)
 line(cx,cy,ax,ay,col)
end

function _init()

 --secret palette!!!
 for i=0,15 do pal(i,i+128,1) end

 mesh = {
  --south
 	{0,0,0, 0,1,0, 1,1,0},
 	{0,0,0, 1,0,0, 1,0,0},
 	--east
 	{1,0,0, 1,1,0, 1,1,1},
 	{1,0,0, 1,1,1, 1,0,1},
 	--north
 	{1,0,1, 1,1,1, 0,1,1},
 	{1,0,1, 0,1,1, 0,0,1},
 	--west
 	{0,0,1, 0,1,1, 0,1,0},
 	{0,0,1, 0,1,0, 0,0,0},
 	--top
 	{0,1,0, 0,1,1, 1,1,1},
 	{0,1,0, 1,1,1, 1,1,0},
 	--bottom
 	{1,0,1, 0,0,1, 0,0,0},
 	{1,0,1, 0,0,0, 1,0,0}
 }
 
 --projection matrix
 fnear = 0.1
 ffar = 1000
 ffov = 15
 ffovrad = 1/tan(ffov*0.5/180*pi)
 
 --matix init
 matproj = create_matrix(4,4)
 matproj[1][1] = ffovrad
 matproj[2][2] = ffovrad
 matproj[3][3] = ffar/(ffar-fnear)
 matproj[4][3] = (-ffar*fnear)/(ffar-fnear)
 matproj[3][4] = 1
 
end

ftheta = 0
function _draw()

 --clear screen
 cls(0)
 
 --set up rotation matrices
 ftheta += 0.02
 matrotz = create_matrix(4,4)
 matrotx = create_matrix(4,4)
 
 --rotation z
 matrotz[1][1] = cos(ftheta)
 matrotz[1][2] = sin(ftheta)
 matrotz[2][1] = -sin(ftheta)
 matrotz[2][2] = cos(ftheta)
 matrotz[3][3] = 1
 matrotz[4][4] = 1
 
 --rotation x
 matrotx[1][1] = 1
 matrotx[2][2] = cos(ftheta*0.5)
 matrotx[2][3] = sin(ftheta*0.5)
 matrotx[3][2] = -sin(ftheta*0.5)
 matrotx[3][3] = cos(ftheta*0.5)
 matrotx[4][4] = 1
 
 --draw triangles
 for i=1,#mesh do
 
  --init triangles
  local triproj = create_triangle()
  local tritrans = create_triangle()
  local trirotz = create_triangle()
  local trirotzx = create_triangle()
  local m = mesh[i]
  local tri = {
   {x=m[1],y=m[2],z=m[3]},
   {x=m[4],y=m[5],z=m[6]},
   {x=m[7],y=m[8],z=m[9]}
  }
  
  --rotate in z-axis
  multiply_mat(tri[1],trirotz[1],matrotz)
  multiply_mat(tri[2],trirotz[2],matrotz)
  multiply_mat(tri[3],trirotz[3],matrotz)
  
  --rotate in x-axis
  multiply_mat(trirotz[1],trirotzx[1],matrotx)
  multiply_mat(trirotz[2],trirotzx[2],matrotx)
  multiply_mat(trirotz[3],trirotzx[3],matrotx)
  
  --offset into the screen
  tritrans = trirotzx
  tritrans[1].z = trirotzx[1].z+3
  tritrans[2].z = trirotzx[2].z+3
  tritrans[3].z = trirotzx[3].z+3
  
  --project tri from 3d-->2d
  multiply_mat(tritrans[1],triproj[1],matproj)
  multiply_mat(tritrans[2],triproj[2],matproj)
  multiply_mat(tritrans[3],triproj[3],matproj)
   
  --scale into view
  triproj[1].x += 1
  triproj[1].y += 1
  triproj[2].x += 1
  triproj[2].y += 1
  triproj[3].x += 1
  triproj[3].y += 1
  triproj[1].x *= 0.5*128
  triproj[1].y *= 0.5*128
  triproj[2].x *= 0.5*128
  triproj[2].y *= 0.5*128
  triproj[3].x *= 0.5*128
  triproj[3].y *= 0.5*128
  
  --rasterize triangle  
  draw_triangle(
   triproj[1].x,
   triproj[1].y,
   triproj[2].x,
   triproj[2].y,
   triproj[3].x,
   triproj[3].y
  )
  
 end

 --title 
 col = flr(rnd(16))
 print("this is 3d rasterization!!!!",9,8,col)
end
__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
