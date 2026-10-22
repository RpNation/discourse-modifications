import dIcon from "discourse/ui-kit/helpers/d-icon";

const TagListIcon = <template>
  {{#if @outletArgs.tags.length}}
    <span class="rpn-tag-list-icon">{{dIcon "tag"}}</span>
  {{/if}}
</template>;

export default TagListIcon;
