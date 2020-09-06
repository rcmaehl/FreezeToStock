# FreezeToStock
Temporarily Pause Non-Required System Processes and Services  | [Download Under Releases](https://github.com/rcmaehl/FreezeToStock/releases)

### What is it?
This project, Freeze to Stock, takes [Sycnex's Windows 10 Debloater script](https://github.com/Sycnex/Windows10Debloater), including others soon, and uses it as baseline for what a debloated system SHOULD look like. You can see it in action [here from JayzTwoCents](https://youtu.be/DcDgV-1zDKs?t=859). Freeze to Stock then turns your PC into this debloated example using a feature added since Windows Vista called process suspension. Microsoft defines this as

*Suspend [a] processes on the local or a remote system, which is desirable in cases where a process is consuming a resource (e.g. network, CPU or disk) that you want to allow different processes to use. Rather than kill the process that's consuming the resource, suspending permits you to let it continue operation at some later point in time.*

In simpler terms, you can essentially use the Hibernate power option for a specific program instead of the entire PC. This will not decrease RAM usage but will **entirely cease CPU usage** for the suspended program. If you've ever seen the below leaf icon in Task Manager it's from a Windows 10 App using it:

![](https://i.imgur.com/cw3oN1y.png)

And it's not just limited to Windows 10 apps, but to almost all processes. Microsoft actually has their own tool for this called [PsSuspend](https://docs.microsoft.com/en-us/sysinternals/downloads/pssuspend) but it's not useful if you don't know what programs you do and don't want to suspend. Additionally, the program pauses Services based on the same debloater script. Once again, Microsoft has their own tool for this called [PsService](https://docs.microsoft.com/en-us/sysinternals/downloads/psservice) but once again you need an idea of what services you want to pause.

So far results have been promising on my 4 year old Windows 10 install (Yes, that is about 40+ chrome tabs open and suspended):

![](https://i.imgur.com/LilskjJ.png)
