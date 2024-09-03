import { appTasks, OhosAppContext, OhosPluginId } from '@ohos/hvigor-ohos-plugin';
import { hvigor,getNode } from '@ohos/hvigor'
import { existsSync, readFileSync } from 'fs';

// Extend the configuration from build-profile.json5 by adding the signing configuration,
// which we read from a file ignored by git, so that users can configure the value locally.
const rootNode = getNode(__filename);
rootNode.afterNodeEvaluate(node => {
    const appContext = node.getContext(OhosPluginId.OHOS_APP_PLUGIN) as OhosAppContext;
    const buildProfileOpt = appContext.getBuildProfileOpt();

    const file_name = './signing-configs.json'
    if(! existsSync(file_name)) {
        console.log("Could not find file %s in the project directory", file_name)
    } else {
        const text = readFileSync(file_name, 'utf-8');
        const configs = JSON.parse(text)
        buildProfileOpt['app']['signingConfigs'] = configs;
    }

    appContext.setBuildProfileOpt(buildProfileOpt);
})

export default {
    system: appTasks,  /* Built-in plugin of Hvigor. It cannot be modified. */
    plugins:[]         /* Custom plugin to extend the functionality of Hvigor. */
}
