#define HTTPD_TEST_REQUIRE_APACHE 2

#if CONFIG_FOR_HTTPD_TEST

Alias /authany @DocumentRoot@
<Location /authany>
   require user any-user
   AuthType Basic
   AuthName authany
</Location>

#endif

#define APACHE_HTTPD_TEST_HOOK_ORDER    APR_HOOK_FIRST
#define APACHE_HTTPD_TEST_CHECK_USER_ID authany_handler
#define APACHE_HTTPD_TEST_AUTH_CHECKER  require_any_user

#include "apache_httpd_test.h"
 
static int require_any_user(request_rec *r)
{
    const apr_array_header_t *requires = ap_requires(r);
    require_line *rq;
    int x;

    if (!requires) {
        return DECLINED;
    }

    rq = (require_line *) requires->elts;

    for (x = 0; x < requires->nelts; x++) {
        const char *line, *requirement;

        line = rq[x].requirement;
        requirement = ap_getword(r->pool, &line, ' ');

        if ((strcmp(requirement, "user") == 0) &&
            (strcmp(line, "any-user") == 0))
        {
            return OK;
        }
    }

    return DECLINED;
}

/* do not accept empty "" strings */
#define strtrue(s) (s && *s)

static int authany_handler(request_rec *r)
{
     const char *sent_pw; 
     int rc = ap_get_basic_auth_pw(r, &sent_pw); 

     if (rc != OK) {
         return rc;
     }

     if (require_any_user(r) != OK) {
         return DECLINED;
     }

     if (!(strtrue(r->user) && strtrue(sent_pw))) {
         ap_note_basic_auth_failure(r);  
#ifdef APACHE2
         /* prototype is different in 1.x */
         ap_log_rerror(APLOG_MARK, APLOG_NOERRNO|APLOG_ERR, 0, r,
                       "Both a username and password must be provided");
#endif
         return HTTP_UNAUTHORIZED;
     }

     return OK;
}

APACHE_HTTPD_TEST_MODULE(authany);
