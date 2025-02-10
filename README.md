本demo用于验证composefs的一些特性

## 文件共享
`composefs`支持在不同的镜像之间共享文件，下面我们来验证一下

准备环境
```bash
prepare.sh
```

上面的脚本会下载`openeuler-24.03-lts `和`openeuler-24.03-lts-sp1 `的 rootfs，并将其解压到当前目录下

```bash
# prepare.sh
# ls
 find-same-file.sh  openeuler:24.03-lts      prepare.sh
 openeuler:24.03-lts-sp1  README.md
```

首先我们来找出两个目录之间相同的文件

```bash
# bash find-same-file.sh openeuler\:24.03-lts/usr/bin openeuler\:24.03-lts-sp1/usr/bin/
...
Files openeuler:24.03-lts/usr/bin/ldd and openeuler:24.03-lts-sp1/usr/bin/ldd are identical
...
```

可以看到不少文件是重复的，例如两个目录的`/usr/bin/ldd`

现在，我们来将2个目录打包成 composefs
```bash
mkcomposefs --digest-store=objects openeuler:24.03-lts-sp1 24.04-lts-sp1.cfs
mkcomposefs --digest-store=objects openeuler:24.03-lts 24.04-lts.cfs
```

这会在`objects`目录中存放基于内容寻址的文件
```bash
# tree objects|more
objects
├── 00
│   ├── 02f99d67e876afc6aa9a403343be122de244518598bd8aece51ffe3ba7aaa2
│   ├── 05904b85173691e71e39753ef899cd12dc90530948c51312eb1c0a5999455a
│   ├── 1dd81480e778372e83038a2b48a5d54450f9759700ccea155e102863465c26
│   ├── 22563393ce2f86d8e2499052e904decc4314bc68bd5022d220f981777f755f
│   ├── 266d8915bf415159824062568ac8e5fb82ef53f8e9cff74113292ea6eaf4f8
│   ├── 2778957347c828957306be290ac2bed12d64bf02dc32e3e78a91a13845606a
│   ├── 487dec543a3aac8e1461310aeb0c4300a61874a7791eba9040a0da6bfa942d
...
```

现在通过composefs-info我们了来查看/usr/bin/ldd是否指向同一个文件

```bash
# composefs-info --basedir=objects ls 24.04-lts-sp1.cfs |grep '/usr/bin/ldd'
/usr/bin/ldd    @ 93/875696648feaf84d3c40aed0d801d53ee910ad6063bb409e9c20a5bb276cfb
# composefs-info --basedir=objects ls 24.04-lts.cfs |grep '/usr/bin/ldd'
/usr/bin/ldd    @ 93/875696648feaf84d3c40aed0d801d53ee910ad6063bb409e9c20a5bb276cfb
```

可以看到，上述两个文件在`objects`目录中指向了同一个`blob`
通过比较，可以看出两个文件内容一致
```bash
# diff objects/93/875696648feaf84d3c40aed0d801d53ee910ad6063bb409e9c20a5bb276cfb openeuler\:24.03-lts/usr/bin/ldd
```

同时，通过对比这几个目录的大小可知，composefs可节省系统存储空间
```bash
du -sh objects/ openeuler\:24.03-lts openeuler\:24.03-lts-sp1/
303M    objects/
182M    openeuler:24.03-lts
182M    openeuler:24.03-lts-sp1/
```
