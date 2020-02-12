package io.agora.education.classroom.adapter;

import android.content.res.Resources;
import android.graphics.Paint;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;

import androidx.annotation.NonNull;

import com.chad.library.adapter.base.BaseProviderMultiAdapter;
import com.chad.library.adapter.base.provider.BaseItemProvider;
import com.chad.library.adapter.base.viewholder.BaseViewHolder;

import java.util.List;

import butterknife.BindView;
import butterknife.ButterKnife;
import io.agora.education.R;
import io.agora.education.classroom.bean.msg.ChannelMsg;

public class MessageListAdapter extends BaseProviderMultiAdapter<ChannelMsg> {

    public MessageListAdapter() {
        addItemProvider(new MeItemProvider());
        addItemProvider(new OtherItemProvider());
        addChildClickViewIds(R.id.tv_content);
    }

    @Override
    protected int getItemType(@NonNull List<? extends ChannelMsg> list, int i) {
        if (list.get(i).isMe) {
            return 0;
        } else {
            return 1;
        }
    }

    class ViewHolder extends BaseViewHolder {
        @BindView(R.id.tv_name)
        TextView tv_name;
        @BindView(R.id.tv_content)
        TextView tv_content;

        ViewHolder(View itemView) {
            super(itemView);
            ButterKnife.bind(this, itemView);
        }

        void convert(ChannelMsg channelMsg) {
            Resources resources = getContext().getResources();
            tv_name.setText(channelMsg.account);
            if (TextUtils.isEmpty(channelMsg.link)) {
                tv_content.setText(channelMsg.content);
                tv_content.setTextColor(resources.getColor(R.color.gray_666666));
                tv_content.getPaint().setFlags(0);
            } else {
                tv_content.setText(R.string.replay_recording);
                tv_content.setTextColor(resources.getColor(R.color.blue_1F3DE8));
                tv_content.getPaint().setFlags(Paint.UNDERLINE_TEXT_FLAG);
            }
        }
    }

    private class MeItemProvider extends BaseItemProvider<ChannelMsg> {
        @Override
        public int getItemViewType() {
            return 0;
        }

        @Override
        public int getLayoutId() {
            return R.layout.item_msg_me;
        }

        @NonNull
        @Override
        public BaseViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
            View view = LayoutInflater.from(getContext()).inflate(getLayoutId(), parent, false);
            return new ViewHolder(view);
        }

        @Override
        public void convert(@NonNull BaseViewHolder baseViewHolder, ChannelMsg channelMsg) {
            if (baseViewHolder instanceof ViewHolder) {
                ((ViewHolder) baseViewHolder).convert(channelMsg);
            }
        }
    }

    private class OtherItemProvider extends BaseItemProvider<ChannelMsg> {
        @Override
        public int getItemViewType() {
            return 1;
        }

        @Override
        public int getLayoutId() {
            return R.layout.item_msg_other;
        }

        @NonNull
        @Override
        public BaseViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
            View view = LayoutInflater.from(getContext()).inflate(getLayoutId(), parent, false);
            return new ViewHolder(view);
        }

        @Override
        public void convert(@NonNull BaseViewHolder baseViewHolder, ChannelMsg channelMsg) {
            if (baseViewHolder instanceof ViewHolder) {
                ((ViewHolder) baseViewHolder).convert(channelMsg);
            }
        }
    }

}
