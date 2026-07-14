
# 这是禁用后，恢复时使用
#pm enable --user 0 com.dudu.flashlight

disable1(){
#第一批：强烈建议禁用（基本安全）
#这些属于明显无用服务：

pm disable-user --user 0 com.huawei.appmarket
pm disable-user --user 0 com.huawei.android.thememanager
pm disable-user --user 0 com.huawei.hidisk
pm disable-user --user 0 com.huawei.himovie
pm disable-user --user 0 com.huawei.videoeditor
pm disable-user --user 0 com.huawei.android.findmyphone
pm disable-user --user 0 com.huawei.parentcontrol
pm disable-user --user 0 com.huawei.hicloud
pm disable-user --user 0 com.huawei.android.clone
pm disable-user --user 0 com.huawei.wallet
pm disable-user --user 0 com.huawei.hicard
pm disable-user --user 0 com.huawei.search
pm disable-user --user 0 com.huawei.vassistant
pm disable-user --user 0 com.huawei.android.instantshare
pm disable-user --user 0 com.huawei.android.instantonline
pm disable-user --user 0 com.huawei.compass
pm disable-user --user 0 com.miui.compass
pm disable-user --user 0 com.glgjing.stark

}


disable2(){
# 第二批：华为生态服务（不用华为服务可以禁）
pm disable-user --user 0 com.huawei.hwid
pm disable-user --user 0 com.huawei.android.pushagent
pm disable-user --user 0 com.huawei.hwid
pm disable-user --user 0 com.huawei.android.hsf
pm disable-user --user 0 com.huawei.nearby
pm disable-user --user 0 com.huawei.hilink.framework
pm disable-user --user 0 com.huawei.iconnect
pm disable-user --user 0 com.huawei.spaceservice
pm disable-user --user 0 com.huawei.hiaction
pm disable-user --user 0 com.huawei.contentsensor
}

disable3(){
# 第三批：运营商/电话相关（你的情况可以禁）
# 你没有 SIM，这些基本没用：
pm disable-user --user 0 com.android.phone
pm disable-user --user 0 com.android.providers.telephony
pm disable-user --user 0 com.android.incallui
pm disable-user --user 0 com.android.mms
pm disable-user --user 0 com.android.mms.service
pm disable-user --user 0 com.android.stk
pm disable-user --user 0 com.android.carrierconfig
pm disable-user --user 0 com.huawei.ims
pm disable-user --user 0 com.huawei.rcsserviceapplication
pm disable-user --user 0 com.huawei.android.AutoRegSms
pm disable-user --user 0 com.huawei.numberidentity
pm disable-user --user 0 com.huawei.cryptosms.service

}

disable4(){
# 第四批：Google 服务（看需求）

#如果你不用：
#
#Play 商店
#Google 登录
#Firebase 推送
#Google APP
#
#可以：
pm disable-user --user 0 com.google.android.gms
pm disable-user --user 0 com.google.android.gsf
pm disable-user --user 0 com.google.android.vending
pm disable-user --user 0 com.google.android.onetimeinitializer
pm disable-user --user 0 com.google.android.partnersetup
pm disable-user --user 0 com.google.android.configupdater
pm disable-user --user 0 com.google.android.printservice.recommendation
pm disable-user --user 0 com.google.android.marvin.talkback

}

disable5(){
# 第五批：辅助功能/打印/梦境
# 第六批：华为诊断/统计/广告类
pm disable-user --user 0 com.android.htmlviewer
pm disable-user --user 0 com.android.dreams.basic
pm disable-user --user 0 com.android.dreams.phototable
pm disable-user --user 0 com.android.printspooler
pm disable-user --user 0 com.google.android.printservice.recommendation
pm disable-user --user 0 com.google.android.marvin.talkback

pm disable-user --user 0 com.huawei.android.UEInfoCheck
pm disable-user --user 0 com.huawei.android.chr
pm disable-user --user 0 com.huawei.hwdetectrepair
pm disable-user --user 0 com.huawei.hwupgradeguide
pm disable-user --user 0 com.huawei.bd
pm disable-user --user 0 com.huawei.mmitest
pm disable-user --user 0 com.huawei.securitymgr
pm disable-user --user 0 com.huawei.trustspace
}


disable1
disable2
disable3

disable5



