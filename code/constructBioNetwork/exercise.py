print(1)

#############################################################################
condition = 1
while condition <10:
    print(condition)
    condition=condition+1
i =0; sum=0##1到9的求和。注意while第一句末尾有个冒号：python 终止while 循环用control +c
while i <10:
    i=i+1
    sum=sum+i 
    print(sum)
#############################################################################





#############################################################################
example_list=[1,2,"emma"]    # for loop
for i in example_list:
	print(i)
	print("inner of for loop")

print("out of for loop")

for i in range(1,10):
	print(i)###注意没有print 10这个末尾值

a_tuple=2,4,6,8##tuple是元组的意思，和list一样，但不需要中括号。tuple不能修改 list可以修改
for i in range(len(a_tuple)):###len(a_tuple)=4,range(4)=0,1,2,3
    print('i=',i,'number is:',a_tuple[i])    
a_list_multi=[[1,2,3],[4,5,6]]####多维列表
print(a_list_multi[0][0])####output=1
dictionary={"apple":[1,2,3],"pear":2,"banana":[1,2,3,4]}####output{'orange': 20, 'apple': [1, 2, 3], 'banana': [1, 2, 3, 4]}
print(dictionary["apple"])
del dictionary["pear"]
print(dictionary)
dictionary["orange"]=20
print(dictionary)
#############################################################################






#############################################################################
x=1;y=2;z=1注意if else 和if elif else语句的else后面也要有冒号：if和else是同一列
if x <y:
	print("x is less than y")
else:
	print("x is no less than y")

if z>1:
	print("z > 1")
elif z ==1:
	print("z=1")
else:
	print("z<1")

if z>1:
	print("z > 1")
elif z <-1:
	print("z<-1")
elif z<1:
	print("z in [-1,1)")
else:
	print("z=1")

for i in range(-5,5):####for loop 可以套if else语句，但是一定要小心具体行前面的四个空格，自己打不行，人家自动给空格。
	print(i)
	if i %2==0:
		print("i %2 =0")
	else:
		print("i %2 !=0")
#############################################################################






#############################################################################
def functiontest(a,b):
	print("This is a function")
	c=a+b
	print("The final result is", c)
functiontest(1,2)

x="apple" ##x是global 变量
def fun():
    a=10
    print(x)
    return(a+100)
print(fun())
#############################################################################


#############################################################################
###sudo pip install numpy   
###sudo pip uninstall numpy
###udo pip install -U numpy 升级
text="This is the first line.\nThis is the second line."###\n是换行的意思
print(text)
myfile=open("myfile.txt","w")###打开一个文档，如果没有则创建一个新的。
myfile.write(text)
myfile.close()

append_text="\nThis is appended text."
myfile=open("myfile.txt","a")###a表示追加一些文字
myfile.write(append_text)
myfile.close()

file=open("myfile.txt","r")
content=file.read()
print(content)########正常输出
file=open("myfile.txt","r")
contents=file.readlines()
print(contents)########output 为一个list:['This is the first line.\n', 'This is the second line.\n', 'This is appended text.']
file=open("myfile.txt","r")
contents=file.readline()
print(contents)########output 只输出第一行
#############################################################################




#############################################################################
a=input("Please input a number:")
print("Your chose number:",a)

a=input("Please input a number no more than 100:")
if a >100:
    print("Wrong,your number is bigger than 100")
else:
    print("Perfect!")
#############################################################################




#############################################################################
import time####time is a module; same results with the following two descriptions
print(time.localtime())

import time as t
print(t.localtime())

from time import time,localtime
print(time())
print(localtime())

from time import*
print(time())
print(localtime())
#############################################################################



#############################################################################
###continue and break 
a=True
while a:
    b=input("please type a number")
    if b==1:
        a=False
    else:
        pass


while True:
    b=input("please type a number")
    if b==1:
        break
    else:
        pass
#####above get the same results.
while True:
    b=input("please type a number but not 1:")
    if b!=1:
        continue
    else:
        print("1 is not satisfied")
        break
#############################################################################