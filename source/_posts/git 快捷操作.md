---
title: git快捷操作
categories: 后端技术
tags:
  - git
cover: https://www.helloimg.com/i/2025/06/06/68428fa6d7a82.jpg
date: 2023-07-04 12:40:00
---

#### git 删除本地分支
git branch -d 本地分支名称  

#### git 删除远程分支  
方式一. git push origin --delete <branch_name>  
方式二. git push origin :<branch_name>  

#### 创建/切换分支操作
git branch (查看本地分支)
git branch -r (查看远程分支)
git branch -a (查看本地和远程分支)
git checkout -b <branch_name> (创建分支)
git branch -m 旧分支  新分支（重命名分支） 
git checkout <branch_name> （切换到指定分支）
git switch <branch_name> （切换分支）
git switch -c <branch_name> （创建新分支）
git checkout <branch_name> <commit_hash> （指定提交切换分支）

#### 合并分支
git merge <branch_name> （将指定分支合并到当前分支） 
‌git cherry-pick‌ <commit_id> （只合并分支提交的改动内容，非整个分支合并） 


#### git丢弃已暂存的修改
git reset HEAD <file> (<file>不指定= 丢弃所有已暂存的文件)  
git reset --hard HEAD （同时丢弃暂存区和工作区的修改） 
此命令将工作区和暂存区重置到最后一次提交的状态，所有未提交的更改都会被丢弃，不可恢复。

#### 取消最近的 commit
git reset --soft HEAD~1 （保留文件变更） 
- --soft：将 HEAD 指针回退到前一个提交（即 HEAD~1），但是保留工作区和暂存区的变更，变 更会被放回到暂存区。 
- HEAD~1：表示上一个提交。 
git reset --hard HEAD~1 (不保留文件变更)  
git reset --hard <commit_id>(回退到某个历史提交)  

#### git 设置‌基础配置
1. 设置用户信息  
git config --global user.name "姓名"  
git config --global user.email "邮箱"  
2. 查看配置‌  
git config --list
git config --global xxx

#### git 文件操作与提交
‌暂存文件‌：
git add [file]（添加指定文件）。
git add .（添加所有修改）。‌‌
1‌‌
‌提交更改‌：git commit -m "提交信息"（含--amend修改最后一次提交）。‌‌
2‌‌
‌状态与差异‌：
git status（查看状态）。
git diff（比较工作区与暂存区）。‌‌

