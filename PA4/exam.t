main:
        BeginFunc 64
        n@1 = 100
        $t0 = n@1
        $t1 = $t0 > 0
        IFZ $t1 Goto L0
        i@1 = 0
        $t2 = i@1
L1:
        $t3 = i@1 < n@1
        IFZ $t3 Goto L2
        $t4 = i@1 * 4
        $t5 = array@1 + $t4
        $t6 = i@1 + 257
        $t7 = $t6 * 2047
        $t8 = $t7 % 99
        *($t5) = $t8
        $t9 = *($t5)
        $t10 = i@1
        i@1 = i@1 + 1
        Goto L1
L2:
L0:
        PushParam 100
        PushParam array@1
        $t11 = LCall qSort
        PopParam 8
        PushParam 100
        PushParam array@1
        $t12 = LCall printArray
        PopParam 8
        Return 0
        EndFunc
qSort:
        BeginFunc 8
        $t13 = #2 - 1
        PushParam $t13
        PushParam 0
        PushParam #1
        $t14 = LCall quickSort
        PopParam 12
        EndFunc
quickSort:
        Left node is NULL!      :: ??
        BeginFunc 156
        $t15 = #2 >= #3
        IFZ $t15 Goto L3
L4:
        IFZ 1 Goto L5
        Return
        Goto L4
L5:
        Goto L6
L3:
        $t16 = #3 * 4
        $t17 = #1 + $t16
        v@1 = *($t17)
        $t18 = v@1
L6:
        i@1 = #2
        $t19 = i@1
        $t20 = $t19 - 1
        pivot@1 = $t20
        $t21 = pivot@1
L7:
        $t22 = i@1 < #3
        IFZ $t22 Goto L8
        $t23 = i@1 * 4
        $t24 = #1 + $t23
        $t25 = *($t24) <= v@1
        IFZ $t25 Goto L9
        $t26 = i@1 * 4
        $t27 = #1 + $t26
        tmp@3 = *($t27)
        $t28 = tmp@3
        $t29 = i@1 * 4
        $t30 = #1 + $t29
        pivot@1 = pivot@1 + 1
        $t31 = pivot@1 * 4
        $t32 = #1 + $t31
        *($t30) = *($t32)
        $t33 = *($t30)
        $t34 = pivot@1 * 4
        $t35 = #1 + $t34
        *($t35) = tmp@3
        $t36 = *($t35)
L9:
        $t37 = i@1
        i@1 = i@1 + 1
        Goto L7
L8:
        $t38 = #3 * 4
        $t39 = #1 + $t38
        pivot@1 = pivot@1 + 1
        $t40 = pivot@1 * 4
        $t41 = #1 + $t40
        *($t39) = *($t41)
        $t42 = *($t39)
        $t43 = pivot@1 * 4
        $t44 = #1 + $t43
        *($t44) = v@1
        $t45 = *($t44)
        $t46 = pivot@1 - 1
        PushParam $t46
        PushParam #2
        PushParam #1
        $t47 = LCall quickSort
        PopParam 12
        PushParam #3
        $t48 = pivot@1 + 1
        PushParam $t48
        PushParam #1
        $t49 = LCall quickSort
        PopParam 12
        EndFunc
printArray:
        BeginFunc 132
        i@1 = 0
        $t50 = i@1
L10:
        $t51 = i@1 % 10
        $t52 = $t51 != 9
        IFZ $t52 Goto L13
        $t53 = $t51 == 4
        IFZ $t53 Goto L14
        $t54 = i@1 * 4
        $t55 = #1 + $t54
        $t56 = *($t55) < 10
        IFZ $t56 Goto L15
        $t57 = i@1 * 4
        $t58 = #1 + $t57
        PushParam *($t58)
        $t59 = LCall printf
        PopParam 4
        Goto L16
L15:
        $t60 = i@1 * 4
        $t61 = #1 + $t60
        PushParam *($t61)
        $t62 = LCall printf
        PopParam 4
L16:
        Goto L12
L13:
        $t63 = i@1 * 4
        $t64 = #1 + $t63
        $t65 = *($t64) < 10
        IFZ $t65 Goto L17
        $t66 = i@1 * 4
        $t67 = #1 + $t66
        PushParam *($t67)
        $t68 = LCall printf
        PopParam 4
        Goto L18
L17:
        $t69 = i@1 * 4
        $t70 = #1 + $t69
        PushParam *($t70)
        $t71 = LCall printf
        PopParam 4
L18:
        Goto L12
L14:
        $t72 = i@1 * 4
        $t73 = #1 + $t72
        $t74 = *($t73) < 10
        IFZ $t74 Goto L19
        $t75 = i@1 * 4
        $t76 = #1 + $t75
        PushParam *($t76)
        $t77 = LCall printf
        PopParam 4
        Goto L20
L19:
        $t78 = i@1 * 4
        $t79 = #1 + $t78
        PushParam *($t79)
        $t80 = LCall printf
        PopParam 4
L20:
L12:
        i@1 = i@1 + 1
        $t81 = i@1 < #2
        IFZ $t81 Goto L11
        Goto L10
L11:
        EndFunc