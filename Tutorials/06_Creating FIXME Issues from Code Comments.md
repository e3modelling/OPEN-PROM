In this tutorial, you can find instructions about automatically creating new issues, by adding a specifically formatted type of comment on your code. This helps us streamline our workflow, and keep track of bugs and other problems. Let's check a simple example, that will help us understand this easily:

```
* FIXME: This is a test issue that was generated automatically
* author=derevirn
VExp.FX(runCy,EFS,YTIME)$(not IMPEF(EFS)) = 0;
VImp.FX(runCy,EFS,YTIME)$(not IMPEF(EFS)) = 0;

VScalFacPlaDisp.LO(runCy, HOUR, YTIME)=-1;
VLambda.LO(runCy,YTIME)=0;
VLambda.L(runCy,YTIME)=0.01;
```
As we can see, this comment starts with `FIXME:`, this is **necessary** so it gets parsed in the correct manner, and subsequently added as a new issue. Afterwards, a brief description of the bug/issue is included, that should be descriptive and brief. As you might expect, this description will be the title of the generated issue. In the next line, we can assign our Github username to the `author` parameter, this is optional but strongly encouraged as a best practice. You should keep in mind that `FIXME` comments will only be converted to issues after a successful pull request, when the branch is merged to `main`. 

<img src="https://github.com/e3modelling/OPEN-PROM/assets/9198526/ea8e73f2-b841-48bf-ab29-5fc21685d715" width="600" >

After making a successfull pull request that includes `FIXME` comments, you can visit the [Issues](https://github.com/e3modelling/OPEN-PROM/issues) page to check them out. As seen in the screenshot above, a snippet of the code is included, along with a link to the associated file. This lets us quickly locate all bugs and deal with them accordingly. Finally, upon deleting the `FIXME` comment from the `main` branch, the issue will (theoretically) be closed. This has proven to be somewhat buggy, so please make sure to confirm it manually yourself! 