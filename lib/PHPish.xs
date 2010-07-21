#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#define sv_is_glob(sv) (SvTYPE(sv) == SVt_PVGV)

#define PERL_VERSION_DECIMAL(r,v,s) (r*1000000 + v*1000 + s)
#define PERL_DECIMAL_VERSION \
	PERL_VERSION_DECIMAL(PERL_REVISION,PERL_VERSION,PERL_SUBVERSION)
#define PERL_VERSION_GE(r,v,s) \
	(PERL_DECIMAL_VERSION >= PERL_VERSION_DECIMAL(r,v,s))

#if PERL_VERSION_GE(5,11,0)
# define sv_is_regexp(sv) (SvTYPE(sv) == SVt_REGEXP)
#else /* <5.11.0 */
# define sv_is_regexp(sv) 0
#endif /* <5.11.0 */

#define sv_is_string(sv) \
	(!sv_is_glob(sv) && !sv_is_regexp(sv) && \
	 (SvFLAGS(sv) & (SVf_IOK|SVf_NOK|SVf_POK|SVp_IOK|SVp_NOK|SVp_POK)))

static HV *array_stash;

static void verify_string(SV* thing) {
    if (!sv_is_string(thing)) {
        croak("Not a string");
    }
}

static bool is_parray(SV *self) {
    SV *aself;
    if (!SvROK(self)) {
        return 0;
    }
    aself = SvRV(self);
    if (!(SvTYPE(aself) == SVt_PVAV)) {
        return 0;
    }
    if (!SvOBJECT(aself)) {
        return 0;
    }
    if (!(SvSTASH(aself) == array_stash)) {
        return 0;
    }
    return 1;
}

static void verify_parray (SV *thing) {
    if (!is_parray(thing)) {
        croak("Not a PHPish::Array");
    }
}





MODULE = PHPish PACKAGE = PHPish

MODULE = PHPish PACKAGE = PHPish::Array

BOOT:
    array_stash = gv_stashpv("PHPish::Array",1);

SV*
new_empty(SV *classname)
PREINIT:
    AV *aself;
CODE:
    aself = newAV();
    RETVAL = newRV_noinc((SV *) aself);
    av_store(aself,0,newRV_noinc((SV *) newAV()));
    av_store(aself,1,newRV_noinc((SV *) newHV()));
    sv_bless(RETVAL,array_stash);
OUTPUT:
    RETVAL

void
push_kv(SV *self, SV *key, SV *value)
PREINIT:
    AV *aself;
    AV *apair;
    SV *pair;
    AV *aseq;
    HV *hlookup;
    I32 index;
CODE:
    verify_parray(self);
    verify_string(key);
    aself = (AV *) SvRV(self);
    apair = newAV();
    av_store(apair,0,newSVsv(key));
    av_store(apair,1,newSVsv(value));
    pair = newRV_noinc((SV *)apair);
    aseq = (AV *) SvRV(*av_fetch(aself,0,0));
    index = av_len(aseq) + 1;
    av_store(aseq,index,pair);
    hlookup = (HV *) SvRV(*av_fetch(aself,1,0));
    hv_store_ent(hlookup, key, newSViv(index), 0);
