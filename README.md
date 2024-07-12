продумати неймінг конвеншн для імен ресурсів базуючись: project_name, enviroment_name,
описати в locals "name_prefix"


Написати validation blocks для всіх input variables:

project_name(length > 5)
enviroment_name(dev, uat, prod)
instance type(only t types)
monitoring(must be true)
root block device size (>= 10, <30)
ebs size(>= 10, <30)
application ports(in range 1-65535)
enviroment owner(email)
ami_id(base of aws ami mask)

Реалізувати логіку, що якщо ami_id передаеться, то брати значення з input variable, якщо не передають, то з дати через фільтр останню версію Ubuntu

Описати на рівні EC2 post/pre condition checks.

Перевіряти, чи name відповідає вашій неймінд конвеншн з врахуванням префікса
Перевіряти, чи включений monitoring
Перевіряти, що інстанс має тег "Owner"

Написати check block для перевірки, що nginx віддає код 200 при зверненні до нього.