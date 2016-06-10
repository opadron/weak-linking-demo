
#ifndef _DEFER_H
#define _DEFER_H

#define CONCAT(A, B) CONCAT_(A, B)
#define CONCAT_(A, B) A##B

#define DEFER_TEMPLATE(INDEX) DEFER_TEMPLATE_(INDEX)
#define DEFER_TEMPLATE_(INDEX) DEFER_TEMPLATE__( \
    CONCAT(____defer____, INDEX),                \
    CONCAT(CONCAT(____defer____, INDEX), _),     \
    CONCAT(____fulfilled____, INDEX)             )

#define DEFER_TEMPLATE__(VAR, DLABEL, FLABEL) \
    unsigned int VAR = 0;                     \
    DLABEL:                                   \
    while(VAR--)                              \
        if(VAR == 0)                          \
            goto FLABEL;                      \
        else /* { CODE BLOCK } */


#define FULFILL_TEMPLATE(INDEX) FULFILL_TEMPLATE_(INDEX)
#define FULFILL_TEMPLATE_(INDEX) FULFILL_TEMPLATE__( \
    CONCAT(____defer____, INDEX),                    \
    CONCAT(CONCAT(____defer____, INDEX), _),         \
    CONCAT(____fulfilled____, INDEX)                 )

#define FULFILL_TEMPLATE__(VAR, DLABEL, FLABEL) \
    VAR = 2;                                    \
    goto DLABEL;                                \
    FLABEL:                                     \
        do {} while(0) /* SEMICOLON */


#define DEFER0 DEFER_TEMPLATE(0)
#define DEFER1 DEFER_TEMPLATE(1)
#define DEFER2 DEFER_TEMPLATE(2)
#define DEFER3 DEFER_TEMPLATE(3)
#define DEFER4 DEFER_TEMPLATE(4)
#define DEFER5 DEFER_TEMPLATE(5)
#define DEFER6 DEFER_TEMPLATE(6)
#define DEFER7 DEFER_TEMPLATE(7)
#define DEFER DEFER0

#define FULFILL0 FULFILL_TEMPLATE(0)
#define FULFILL1 FULFILL_TEMPLATE(1)
#define FULFILL2 FULFILL_TEMPLATE(2)
#define FULFILL3 FULFILL_TEMPLATE(3)
#define FULFILL4 FULFILL_TEMPLATE(4)
#define FULFILL5 FULFILL_TEMPLATE(5)
#define FULFILL6 FULFILL_TEMPLATE(6)
#define FULFILL7 FULFILL_TEMPLATE(7)
#define FULFILL FULFILL0

#endif /* !_DEFER_H */

