In this tutorial, you can find instructions about automatically creating new issues, by adding a specifically formatted type of comment on your code. This helps us streamline our workflow, and keep track of bugs and other problems. Let's check a simple example, that will help us understand this easily:

```
* FIXME: This is a test issue that was generated automatically
* author=derevirn
VExportsFake.FX(runCy,EFS,YTIME)$(not IMPEF(EFS)) = 0;
VFkImpAllFuelsNotNatGas.FX(runCy,EFS,YTIME)$(not IMPEF(EFS)) = 0;

VScalFacPlaDisp.LO(runCy, HOUR, YTIME)=-1;
VLoadCurveConstr.LO(runCy,YTIME)=0;
VLoadCurveConstr.L(runCy,YTIME)=0.01;
```
As we can see, this comment starts with `FIXME:`, this is **necessary** so it gets parsed in the correct manner, and subsequently added as a new issue. Afterwards, a brief description of the bug/issue is included, that should be descriptive and brief. As you might expect, this description will be the title of the generated issue. 



